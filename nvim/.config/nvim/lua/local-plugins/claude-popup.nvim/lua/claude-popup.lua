-- claude-popup.nvim - A simple Neovim plugin for Claude AI in a popup window
-- Structure:
-- 1. Plugin setup and configuration
-- 2. API connection functions
-- 3. UI functions (popup, input handling)
-- 4. Keymappings and commands

local M = {}

-- ============================================================================
-- Plugin Configuration
-- ============================================================================

-- Default plugin configuration
local default_config = {
  -- API configuration
  api = {
    model = "claude-3-7-sonnet-20250219", -- The Claude model to use
    api_key = nil,                        -- Set your API key here or use env var
    api_key_env = "ANTHROPIC_API_KEY",    -- Environment variable for API key
    endpoint = "https://api.anthropic.com/v1/messages",
    max_tokens = 2000,                    -- Max tokens to generate
    temperature = 0.7,                    -- Controls randomness (0.0-1.0)
  },

  -- UI configuration
  ui = {
    width = 0.7,              -- Width as a percentage of screen width
    height = 0.6,             -- Height as a percentage of screen height
    border = "rounded",       -- Border style: "none", "single", "double", "rounded", "solid"
    title = " Claude AI ",    -- Title shown in the popup window border
    win_options = {           -- Window options
      wrap = true,            -- Enable text wrapping
      linebreak = true,       -- Break lines at word boundaries
      cursorline = false,     -- Disable cursor line highlighting
      foldenable = false,     -- Disable folding
      number = false,         -- Hide line numbers
      relativenumber = false, -- Hide relative line numbers
      signcolumn = "no",      -- Hide sign column
    },
    colors = {
      user_prompt = "Comment",       -- Color group for user messages
      assistant_response = "Normal", -- Color group for Claude's responses
      thinking = "Comment",          -- Color for "thinking..." indicator
      error = "ErrorMsg",            -- Color for error messages
    },
  },

  -- Keymappings
  keymaps = {
    toggle = "<leader>cc", -- Toggle Claude popup visibility
    submit = "<C-s>",      -- Submit a message in insert mode
    clear = "<C-l>",       -- Clear the chat history
  },

  -- Chat behavior
  chat = {
    save_history = true,                                             -- Whether to save chat history between sessions
    history_file = vim.fn.stdpath("data") .. "/claude_history.json", -- Chat history location
    initial_message = "Hello! I'm Claude. How can I help you with your code today?",
  },
}

-- User configuration
local config = {}

-- Initialize the plugin with user configuration
function M.setup(user_config)
  -- Merge default config with user config
  config = vim.tbl_deep_extend("force", default_config, user_config or {})

  -- Setup commands
  vim.api.nvim_create_user_command("ClaudeToggle", M.toggle_popup, {})
  vim.api.nvim_create_user_command("ClaudeClear", M.clear_chat, {})

  -- Setup keymappings
  if config.keymaps.toggle then
    vim.api.nvim_set_keymap(
      "n",
      config.keymaps.toggle,
      ":ClaudeToggle<CR>",
      { noremap = true, silent = true, desc = "Toggle Claude AI popup" }
    )
  end

  -- Initialize UI state
  M.init_state()
end

-- ============================================================================
-- State Management
-- ============================================================================

-- Initialize plugin state
function M.init_state()
  M.state = {
    buf_id = nil,             -- Buffer ID for the popup
    win_id = nil,             -- Window ID for the popup
    input_buf_id = nil,       -- Buffer ID for the input field
    input_win_id = nil,       -- Window ID for the input field
    is_visible = false,       -- Whether the popup is currently visible
    waiting_response = false, -- Whether we're waiting for a response
    chat_history = {},        -- Chat history
    message_marks = {},       -- Marks for each message in history
  }

  -- Try to load chat history if it exists and saving is enabled
  if config.chat.save_history then
    M.load_chat_history()
  end
end

-- Load chat history from file
function M.load_chat_history()
  local history_file = config.chat.history_file

  -- Check if history file exists
  if vim.fn.filereadable(history_file) == 0 then
    return
  end

  -- Read and parse history file
  local file = io.open(history_file, "r")
  if not file then return end

  local content = file:read("*all")
  file:close()

  -- Parse JSON content
  local ok, history = pcall(vim.fn.json_decode, content)
  if ok and type(history) == "table" then
    M.state.chat_history = history
  end
end

-- Save chat history to file
function M.save_chat_history()
  if not config.chat.save_history then
    return
  end

  local history_file = config.chat.history_file
  local file = io.open(history_file, "w")
  if not file then
    M.show_error("Failed to save chat history")
    return
  end

  -- Convert history to JSON and save
  local json = vim.fn.json_encode(M.state.chat_history)
  file:write(json)
  file:close()
end

-- ============================================================================
-- API Connection Functions
-- ============================================================================

-- Get API key from config or environment variable
function M.get_api_key()
  -- First check if API key is set in config
  if config.api.api_key then
    return config.api.api_key
  end

  -- Otherwise try to get it from environment variable
  local api_key = os.getenv(config.api.api_key_env)
  if not api_key or api_key == "" then
    M.show_error("API key not found. Please set it in config or " .. config.api.api_key_env .. " environment variable.")
    return nil
  end

  return api_key
end

-- Send a message to the Claude API
function M.send_to_claude(messages, callback)
  local api_key = M.get_api_key()
  if not api_key then
    return
  end

  -- Format the messages for Claude's API
  local formatted_messages = M.format_messages_for_api(messages)

  -- Prepare the request data
  local request_data = {
    model = config.api.model,
    max_tokens = config.api.max_tokens,
    temperature = config.api.temperature,
    messages = formatted_messages,
  }

  -- Convert request data to JSON
  local json_data = vim.fn.json_encode(request_data)

  -- Create a temporary file for curl output
  local temp_file = os.tmpname()

  -- Create the curl command
  local cmd = string.format(
    "curl -s -X POST %s " ..
    "-H 'x-api-key: %s' " ..
    "-H 'anthropic-version: 2023-06-01' " ..
    "-H 'content-type: application/json' " ..
    "-d '%s' > %s",
    config.api.endpoint,
    api_key,
    json_data:gsub("'", "'\\''"), -- Escape single quotes
    temp_file
  )

  -- Set the waiting flag
  M.state.waiting_response = true

  -- Show thinking indicator
  M.add_thinking_indicator()

  -- Run the curl command in the background
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      M.state.waiting_response = false
      M.remove_thinking_indicator()

      if exit_code ~= 0 then
        M.show_error("API request failed with exit code: " .. exit_code)
        return
      end

      -- Read response from temp file
      local file = io.open(temp_file, "r")
      if not file then
        M.show_error("Failed to read API response")
        return
      end

      local response = file:read("*all")
      file:close()
      os.remove(temp_file)

      -- Parse JSON response
      local ok, parsed = pcall(vim.fn.json_decode, response)
      if not ok or not parsed then
        M.show_error("Failed to parse API response")
        return
      end

      -- Check for API errors
      if parsed.error then
        M.show_error("API error: " .. (parsed.error.message or "Unknown error"))
        return
      end

      -- Extract response content
      local content = parsed.content or {}
      local response_text = ""

      -- Get text from all text blocks
      for _, part in ipairs(content) do
        if part.type == "text" then
          response_text = response_text .. part.text
        end
      end

      -- Call the callback with the response
      if callback then
        callback(response_text)
      end
    end
  })
end

-- Format messages for Claude API
function M.format_messages_for_api(messages)
  local formatted = {}

  for _, msg in ipairs(messages) do
    table.insert(formatted, {
      role = msg.role,
      content = msg.content
    })
  end

  return formatted
end

-- ============================================================================
-- UI Functions
-- ============================================================================

-- Create the Claude popup window
function M.create_popup()
  -- Calculate dimensions
  local width = math.floor(vim.o.columns * config.ui.width)
  local height = math.floor(vim.o.lines * config.ui.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create buffer if it doesn't exist
  if not M.state.buf_id or not vim.api.nvim_buf_is_valid(M.state.buf_id) then
    M.state.buf_id = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(M.state.buf_id, "buftype", "nofile")
    vim.api.nvim_buf_set_option(M.state.buf_id, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(M.state.buf_id, "swapfile", false)
    vim.api.nvim_buf_set_option(M.state.buf_id, "filetype", "markdown")
  end

  -- Create window for the popup
  M.state.win_id = vim.api.nvim_open_win(M.state.buf_id, true, {
    relative = "editor",
    width = width,
    height = height - 3, -- Reserve space for input
    row = row,
    col = col,
    border = config.ui.border,
    title = config.ui.title,
    style = "minimal",
    zindex = 50,
  })

  -- Set window options
  for option, value in pairs(config.ui.win_options) do
    vim.api.nvim_win_set_option(M.state.win_id, option, value)
  end

  -- Create input buffer
  if not M.state.input_buf_id or not vim.api.nvim_buf_is_valid(M.state.input_buf_id) then
    M.state.input_buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "buftype", "nofile")
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "swapfile", false)
  end

  -- Create input window
  M.state.input_win_id = vim.api.nvim_open_win(M.state.input_buf_id, false, {
    relative = "editor",
    width = width,
    height = 3,
    row = row + height - 3,
    col = col,
    border = config.ui.border,
    title = " Message ",
    style = "minimal",
    zindex = 50,
  })

  -- Set input window options
  vim.api.nvim_win_set_option(M.state.input_win_id, "wrap", true)
  vim.api.nvim_win_set_option(M.state.input_win_id, "cursorline", false)

  -- Set local keymaps for both the main window and input window
  local buffer_maps = {
    [config.keymaps.clear] = "lua require('claude-popup').clear_chat()",
    ["<Esc>"] = "lua require('claude-popup').toggle_popup()",
    ["<C-[>"] = "lua require('claude-popup').toggle_popup()",
    [config.keymaps.toggle] = "lua require('claude-popup').toggle_popup()",
  }

  -- Apply keymaps to both windows
  for key, cmd in pairs(buffer_maps) do
    if key then
      -- Main popup window
      vim.api.nvim_buf_set_keymap(M.state.buf_id, "n", key, ":" .. cmd .. "<CR>", { noremap = true, silent = true })

      -- Input window (normal mode)
      vim.api.nvim_buf_set_keymap(M.state.input_buf_id, "n", key, ":" .. cmd .. "<CR>", { noremap = true, silent = true })
    end
  end

  -- Simple escape to normal mode for insert mode
  vim.api.nvim_buf_set_keymap(
    M.state.input_buf_id,
    "i",
    "<C-q>",
    "<Esc>",
    { noremap = true, silent = true }
  )

  -- Set keymaps for the input buffer
  -- Simple, ergonomic keymappings:
  -- 1. Enter in normal mode to submit
  -- 2. Ctrl+c in insert mode to submit (single press)

  -- Enter key in normal mode - the primary submission method
  vim.api.nvim_buf_set_keymap(
    M.state.input_buf_id,
    "n",
    "<CR>",
    ":lua require('claude-popup').submit_message()<CR>",
    { noremap = true, silent = true }
  )

  -- <C-CR> in insert mode - allows submitting without leaving insert mode
  -- This is a terminal-specific keybinding and may need special terminal configuration
  vim.api.nvim_buf_set_keymap(
    M.state.input_buf_id,
    "i",
    "<C-CR>",
    "<Esc>:lua require('claude-popup').submit_message()<CR>",
    { noremap = true, silent = true }
  )

  -- More ergonomic alternative for insert mode - single key press
  vim.api.nvim_buf_set_keymap(
    M.state.input_buf_id,
    "i",
    "<C-s>",
    "<Esc>:lua require('claude-popup').submit_message()<CR>",
    { noremap = true, silent = true }
  )

  -- Focus the input window and enter insert mode
  vim.api.nvim_set_current_win(M.state.input_win_id)
  vim.cmd("startinsert")

  -- Display chat history
  M.display_chat_history()

  -- Add initial message if needed
  if #M.state.chat_history == 0 and config.chat.initial_message then
    M.add_message("assistant", config.chat.initial_message)
  end

  -- Set visibility flag
  M.state.is_visible = true
end

-- Toggle the Claude popup visibility
function M.toggle_popup()
  if M.state.is_visible then
    M.close_popup()
  else
    M.create_popup()
  end
end

-- Close the Claude popup
function M.close_popup()
  -- Save chat history before closing
  M.save_chat_history()

  -- Close both windows at once
  if M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
    vim.api.nvim_win_close(M.state.input_win_id, true)
  end

  if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
    vim.api.nvim_win_close(M.state.win_id, true)
  end

  -- Reset window IDs
  M.state.win_id = nil
  M.state.input_win_id = nil

  -- Update visibility state
  M.state.is_visible = false
end

-- Submit a message to Claude
function M.submit_message()
  -- Don't submit if we're already waiting for a response
  if M.state.waiting_response then
    vim.notify("Claude is still thinking...", vim.log.levels.INFO)
    return
  end

  -- Get the message from the input buffer
  local lines = vim.api.nvim_buf_get_lines(M.state.input_buf_id, 0, -1, false)
  local message = table.concat(lines, "\n")

  -- Don't submit empty messages
  if message:match("^%s*$") then
    vim.notify("Cannot send empty message", vim.log.levels.WARN)
    return
  end

  -- Clear the input buffer
  vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, { "" })

  -- Add the message to the chat
  M.add_message("user", message)

  -- Flash input border to give visual feedback for submission
  local original_border = config.ui.border
  local width = math.floor(vim.o.columns * config.ui.width)
  local height = math.floor(vim.o.lines * config.ui.height)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  if M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
    vim.api.nvim_win_set_config(M.state.input_win_id, {
      border = "double",
    })

    vim.defer_fn(function()
      if M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
        vim.api.nvim_win_set_config(M.state.input_win_id, {
          border = original_border,
        })
      end
    end, 150)
  end

  -- Focus the chat window to see Claude's reply
  vim.api.nvim_set_current_win(M.state.win_id)

  -- Prepare messages for the API
  local api_messages = {}
  for _, msg in ipairs(M.state.chat_history) do
    table.insert(api_messages, msg)
  end

  -- Send to Claude API
  M.send_to_claude(api_messages, function(response)
    -- Add response to chat
    M.add_message("assistant", response)

    -- Notify user when response is ready
    vim.notify("Claude has responded!", vim.log.levels.INFO)

    -- Focus the input window again
    if M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
      vim.api.nvim_set_current_win(M.state.input_win_id)
      vim.cmd("startinsert")
    end
  end)
end

-- Add a message to the chat
function M.add_message(role, content)
  -- Add to the chat history
  table.insert(M.state.chat_history, {
    role = role,
    content = content
  })

  -- Update the display
  M.display_chat_history()
end

-- Display the chat history in the popup
function M.display_chat_history()
  if not M.state.buf_id or not vim.api.nvim_buf_is_valid(M.state.buf_id) then
    return
  end

  -- Clear message marks
  M.state.message_marks = {}

  -- Convert chat history to displayable format
  local display_lines = {}

  for i, msg in ipairs(M.state.chat_history) do
    local prefix = msg.role == "user" and "You: " or "Claude: "
    local color = msg.role == "user" and config.ui.colors.user_prompt or config.ui.colors.assistant_response

    -- Add blank line before message (except the first one)
    if i > 1 then
      table.insert(display_lines, "")
    end

    -- Set the start line for this message
    local start_line = #display_lines + 1

    -- Add the prefix line
    table.insert(display_lines, prefix)

    -- Add content lines with proper wrapping
    local content_lines = vim.split(msg.content, "\n")
    for _, line in ipairs(content_lines) do
      table.insert(display_lines, line)
    end

    -- Store message mark for highlighting
    table.insert(M.state.message_marks, {
      role = msg.role,
      start_line = start_line,
      end_line = #display_lines,
      color = color
    })
  end

  -- Update buffer content
  vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", true)
  vim.api.nvim_buf_set_lines(M.state.buf_id, 0, -1, false, display_lines)
  vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", false)

  -- Apply highlighting
  M.apply_highlighting()

  -- Scroll to the bottom
  if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
    local line_count = #display_lines
    -- Only set cursor if there are actually lines in the buffer
    if line_count > 0 then
      vim.api.nvim_win_set_cursor(M.state.win_id, { line_count, 0 })
      vim.cmd("normal! zz")
    end
  end
end

-- Apply highlighting to the chat messages
function M.apply_highlighting()
  if not M.state.buf_id or not vim.api.nvim_buf_is_valid(M.state.buf_id) then
    return
  end

  -- Clear existing highlighting
  vim.api.nvim_buf_clear_namespace(M.state.buf_id, 0, 0, -1)

  -- Apply highlighting for each message
  for _, mark in ipairs(M.state.message_marks) do
    local ns_id = vim.api.nvim_create_namespace("claude_popup_" .. mark.role)

    for line = mark.start_line, mark.end_line do
      vim.api.nvim_buf_add_highlight(M.state.buf_id, ns_id, mark.color, line - 1, 0, -1)
    end
  end
end

-- Show a thinking indicator
function M.add_thinking_indicator()
  if not M.state.buf_id or not vim.api.nvim_buf_is_valid(M.state.buf_id) then
    return
  end

  -- Add thinking indicator to buffer
  vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", true)

  local lines = vim.api.nvim_buf_get_lines(M.state.buf_id, 0, -1, false)
  table.insert(lines, "")
  table.insert(lines, "Claude: ")
  table.insert(lines, "Thinking...")

  vim.api.nvim_buf_set_lines(M.state.buf_id, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", false)

  -- Highlight the thinking text
  local ns_id = vim.api.nvim_create_namespace("claude_popup_thinking")
  vim.api.nvim_buf_add_highlight(M.state.buf_id, ns_id, config.ui.colors.thinking, #lines - 1, 0, -1)

  -- Scroll to the bottom
  if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
    local line_count = #lines
    if line_count > 0 then
      vim.api.nvim_win_set_cursor(M.state.win_id, { line_count, 0 })
    end
  end
end

-- Remove the thinking indicator
function M.remove_thinking_indicator()
  if not M.state.buf_id or not vim.api.nvim_buf_is_valid(M.state.buf_id) then
    return
  end

  -- We'll just redisplay the chat history without the indicator
  M.display_chat_history()
end

-- Show an error message
function M.show_error(message)
  -- Display error in the popup if it exists
  if M.state.buf_id and vim.api.nvim_buf_is_valid(M.state.buf_id) then
    vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", true)

    local lines = vim.api.nvim_buf_get_lines(M.state.buf_id, 0, -1, false)
    table.insert(lines, "")
    table.insert(lines, "Error: " .. message)

    vim.api.nvim_buf_set_lines(M.state.buf_id, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", false)

    -- Highlight the error text
    local ns_id = vim.api.nvim_create_namespace("claude_popup_error")
    vim.api.nvim_buf_add_highlight(M.state.buf_id, ns_id, config.ui.colors.error, #lines - 1, 0, -1)
  else
    -- Otherwise use vim.notify
    vim.notify("Claude AI Error: " .. message, vim.log.levels.ERROR)
  end
end

-- Clear the chat history
function M.clear_chat()
  -- Clear the history
  M.state.chat_history = {}

  -- Update the display
  M.display_chat_history()

  -- Add initial message if configured
  if config.chat.initial_message then
    M.add_message("assistant", config.chat.initial_message)
  end
end

-- Return the module
return M
