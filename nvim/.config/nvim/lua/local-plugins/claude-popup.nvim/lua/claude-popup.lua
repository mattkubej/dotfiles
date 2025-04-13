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
      scrolloff = 5,          -- Keep 5 lines visible above/below cursor when scrolling
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
    toggle = "<leader>cc",            -- Toggle Claude popup visibility
    submit = "<C-s>",                 -- Submit a message in insert mode
    clear = "<C-l>",                  -- Clear the chat history
    ask_buffer = "<leader>cb",        -- Ask about current buffer (adds buffer context)
    ask_selection = "<leader>cs",     -- Ask about selected code (adds selection context)
    improve_selection = "<leader>ci", -- Ask Claude to improve selected code
    explain_selection = "<leader>ce", -- Ask Claude to explain selected code
    implement_comment = "<leader>cp", -- Ask Claude to implement code from comment selection
  },

  -- Chat behavior
  chat = {
    save_history = true,                                             -- Whether to save chat history between sessions
    history_file = vim.fn.stdpath("data") .. "/claude_history.json", -- Chat history location
    initial_message = "Hello! I'm Claude. How can I help you with your code today?",
  },

  -- Code interaction prompts
  code_prompts = {
    -- Predefined prompts for different code interactions (detail is hidden from UI)
    improve = {
      summary = "Improving selected code...",
      prompt =
      "As an expert programmer, please improve this code. Focus on:\n- Performance optimization\n- Better readability and code organization\n- Proper error handling and edge cases\n- Following language-specific best practices and idioms\n- Maintaining the original functionality\n\nProvide only the improved code without explanations unless there's something critical I should know:",
    },
    explain = {
      summary = "Explaining selected code...",
      prompt =
      "Please explain this code comprehensively:\n- Overall purpose and functionality\n- How each part contributes to the whole\n- Key algorithms or patterns used\n- Any non-obvious techniques or optimizations\n- Potential edge cases or limitations\n- Context of how this would fit into a larger system\n\nFormat your explanation clearly with sections and bullet points where appropriate:",
    },
    implement = {
      summary = "Implementing code from comments...",
      prompt =
      "Please implement code based on this comment/specification. Your implementation should:\n- Follow best practices for the language\n- Include appropriate error handling\n- Be well-structured and maintainable\n- Include helpful comments where needed\n- Be optimized for readability and performance\n\nProvide the complete implementation without explanations unless there are important design decisions to highlight:",
    },
    -- Add alias for implement_comment
    implement_comment = {
      summary = "Implementing code from comments...",
      prompt =
      "Please implement code based on this comment/specification. Your implementation should:\n- Follow best practices for the language\n- Include appropriate error handling\n- Be well-structured and maintainable\n- Include helpful comments where needed\n- Be optimized for readability and performance\n\nProvide the complete implementation without explanations unless there are important design decisions to highlight:",
    },
    analyze = {
      summary = "Analyzing code for issues and improvements...",
      prompt =
      "Please analyze this code for:\n- Potential bugs or edge cases\n- Performance bottlenecks\n- Security vulnerabilities\n- Code smells or maintenance issues\n- Opportunities for simplification\n- Adherence to best practices\n\nOrganize your analysis by priority, focusing on the most important issues first:",
    },
    buffer = {
      summary = "Analyzing current file...",
      prompt =
      "Please help me understand this file. I'd like you to:\n- Summarize the overall purpose and functionality\n- Identify key components, classes, or functions\n- Explain the relationships between different parts\n- Note any interesting patterns or techniques used\n- Highlight potential issues or areas for improvement\n\nPlease be thorough but prioritize the most important aspects:",
    },
    custom = {
      summary = "Discussing selected code...",
      prompt =
      "I've selected some code and would like your insights on it. Please help me understand or improve this code based on our conversation.",
    },
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
  vim.api.nvim_create_user_command("ClaudeAskBuffer", M.ask_buffer, {})

  -- Commands that work with selection need to allow range
  vim.api.nvim_create_user_command("ClaudeAskSelection", M.ask_selection, { range = true })
  vim.api.nvim_create_user_command("ClaudeImproveSelection", M.code_action("improve"), { range = true })
  vim.api.nvim_create_user_command("ClaudeExplainSelection", M.code_action("explain"), { range = true })
  vim.api.nvim_create_user_command("ClaudeImplementComment", M.code_action("implement_comment"), { range = true })
  vim.api.nvim_create_user_command("ClaudeAnalyzeSelection", M.code_action("analyze"), { range = true })

  -- Setup keymappings
  local keymaps = {
    toggle = { mode = "n", cmd = ":ClaudeToggle<CR>", desc = "Toggle Claude AI popup" },
    ask_buffer = { mode = "n", cmd = ":ClaudeAskBuffer<CR>", desc = "Ask Claude about current buffer" },
  }

  -- Set up visual mode mappings with special handling
  local visual_keymaps = {
    ask_selection = { cmd = "ClaudeAskSelection", desc = "Ask Claude about selection" },
    improve_selection = { cmd = "ClaudeImproveSelection", desc = "Ask Claude to improve selection" },
    explain_selection = { cmd = "ClaudeExplainSelection", desc = "Ask Claude to explain selection" },
    implement_comment = { cmd = "ClaudeImplementComment", desc = "Ask Claude to implement from comment" },
  }

  -- Apply normal mode keymaps
  for key, keymap_info in pairs(keymaps) do
    if config.keymaps[key] then
      vim.api.nvim_set_keymap(
        keymap_info.mode,
        config.keymaps[key],
        keymap_info.cmd,
        { noremap = true, silent = true, desc = keymap_info.desc }
      )
    end
  end

  -- Set up visual mode mappings
  for key, keymap_info in pairs(visual_keymaps) do
    if config.keymaps[key] then
      -- Use standard visual range notation to pass the selection
      vim.cmd(string.format(
        "xnoremap <silent> %s :'<,'>%s<CR>",
        config.keymaps[key],
        keymap_info.cmd
      ))
    end
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
    buf_id = nil,                      -- Buffer ID for the popup
    win_id = nil,                      -- Window ID for the popup
    input_buf_id = nil,                -- Buffer ID for the input field
    input_win_id = nil,                -- Window ID for the input field
    is_visible = false,                -- Whether the popup is currently visible
    waiting_response = false,          -- Whether we're waiting for a response
    chat_history = {},                 -- Chat history
    message_marks = {},                -- Marks for each message in history
    selected_code = nil,               -- Selected code for custom queries
    stored_custom_prompt = nil,        -- Stored prompt template for custom queries
    thinking_indicator_active = false, -- Whether a thinking indicator is currently showing
    original_assistant_message = nil,  -- Original content of assistant message before adding thinking indicator
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

  -- Convert request data to JSON and ensure it's properly escaped
  local json_data = vim.fn.json_encode(request_data)

  -- Create a temporary file for the request data
  local request_file = os.tmpname()
  local file = io.open(request_file, "w")
  if not file then
    hide_status()
    vim.notify("Failed to create temporary file for request", vim.log.levels.ERROR)
    return
  end

  -- Write the JSON data to the file
  file:write(json_data)
  file:close()

  -- Create a temporary file for curl output
  local temp_file = os.tmpname()

  -- Create the curl command using --data-binary @file to avoid escaping issues
  local cmd = string.format(
    "curl -s -X POST %s " ..
    "-H 'x-api-key: %s' " ..
    "-H 'anthropic-version: 2023-06-01' " ..
    "-H 'content-type: application/json' " ..
    "--data-binary @%s > %s",
    config.api.endpoint,
    api_key,
    request_file,
    temp_file
  )

  -- Set the waiting flag
  M.state.waiting_response = true

  -- Show thinking indicator
  M.add_thinking_indicator()

  -- Keep focus in the input window while waiting for response
  if M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
    vim.api.nvim_set_current_win(M.state.input_win_id)
  end

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
-- Code Context Helper Functions
-- ============================================================================

-- Modified function to properly get buffer content
function M.get_buffer_content()
  -- Get the buffer number of the current buffer
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get file path to confirm which buffer we're using (for debugging)
  local file_path = vim.api.nvim_buf_get_name(bufnr)

  -- Get buffer lines
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Log information for debugging
  vim.notify("Reading buffer #" .. bufnr .. " (" .. file_path .. ") with " .. #lines .. " lines", vim.log.levels.INFO)

  -- If content is empty, notify to help diagnose the issue
  if content == "" then
    vim.notify("Warning: Buffer content appears to be empty", vim.log.levels.WARN)
  end

  return content
end


-- Get the filetype of the current buffer
function M.get_current_filetype()
  return vim.bo.filetype
end

-- Get the visual selection text - works even after visual mode is exited
function M.get_visual_selection()
  -- Get the line numbers of the selection
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- Safety check for valid selection
  if start_line <= 0 or end_line <= 0 then
    vim.notify("No valid selection marks found", vim.log.levels.WARN)
    return ""
  end

  -- Get the columns of the selection
  local start_col = vim.fn.col("'<")
  local end_col = vim.fn.col("'>")

  -- Get the selection mode that was used
  local mode = vim.fn.visualmode()

  -- Get the selected lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Nothing was selected
  if #lines == 0 then
    return ""
  end

  -- If it's just one line, extract the substring
  if #lines == 1 and mode == 'v' then
    lines[1] = string.sub(lines[1], start_col, end_col)
  elseif mode == 'v' and #lines > 1 then
    -- For multi-line character-wise selection
    -- Adjust first and last line
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  -- Line-wise (V) and block-wise (^V) modes will just use the full lines

  -- Join the lines and return
  return table.concat(lines, '\n')
end

-- Format code with its filetype for better context
function M.format_code_context(code, filetype)
  return string.format("```%s\n%s\n```", filetype or "", code)
end

-- Fill a prompt and optionally submit immediately
function M.fill_prompt_and_submit(prompt, auto_submit)
  -- Set the prompt in the input buffer
  vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, vim.split(prompt, "\n"))

  if auto_submit then
    -- Submit immediately
    vim.defer_fn(function()
      M.submit_message()
    end, 100) -- Small delay to ensure UI updates
  else
    -- Focus the input window for editing
    vim.api.nvim_set_current_win(M.state.input_win_id)
    -- Place cursor at the beginning for easy editing
    vim.api.nvim_win_set_cursor(M.state.input_win_id, { 1, 0 })
    vim.cmd("startinsert")
  end
end

-- Fill with display prompt but submit a different full prompt
-- This allows hiding verbose prompts from the UI while still sending them to Claude
function M.fill_prompt_and_submit_with_hidden_prompt(display_prompt, full_prompt)
  -- Set the display prompt in the input buffer (what user sees)
  vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, vim.split(display_prompt, "\n"))

  -- Submit with delay to ensure UI updates
  vim.defer_fn(function()
    -- Store original message to display
    local display_message = table.concat(vim.api.nvim_buf_get_lines(M.state.input_buf_id, 0, -1, false), "\n")

    -- Replace with the full prompt before submission
    vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, vim.split(full_prompt, "\n"))

    -- Custom submit that preserves display message
    M.submit_message_with_display(display_message)
  end, 100)
end

function M.ask_buffer()
  -- Store the original buffer number before opening popup
  local original_bufnr = vim.api.nvim_get_current_buf()
  local original_file = vim.api.nvim_buf_get_name(original_bufnr)

  -- First ensure the popup is open
  if not M.state.is_visible then
    M.create_popup()
  end

  -- Make sure we get content from the original buffer, not the popup
  local content = ""
  -- Check if original buffer is still valid
  if vim.api.nvim_buf_is_valid(original_bufnr) then
    -- Get the buffer content directly from the original buffer
    local lines = vim.api.nvim_buf_get_lines(original_bufnr, 0, -1, false)
    content = table.concat(lines, "\n")

    -- Get the filetype of the original buffer
    local filetype = vim.api.nvim_buf_get_option(original_bufnr, "filetype")

    -- Clear existing chat history for focused interaction (optional)
    M.clear_chat(true) -- silent clear

    -- If content is empty, show warning instead of proceeding
    if content == "" or content:match("^%s*$") then
      M.add_message("assistant",
        "The buffer appears to be empty. Please make sure you're in a buffer with content when using this command.")
      return
    end

    -- Store a reference to the buffer content for message formatting
    M.state.selected_code = M.format_code_context(content, filetype)
    
    -- Store the prompt template (hidden from UI)
    local full_prompt = config.code_prompts.buffer.prompt
    M.state.stored_custom_prompt = full_prompt

    -- Show a user-friendly message in chat
    M.add_message("assistant", "I'm ready to answer questions about this buffer. What would you like to know?")

    -- For custom queries, we show a helpful placeholder in the input box
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "modifiable", true)
    vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, { "" })

    -- Focus the input window for editing
    vim.api.nvim_set_current_win(M.state.input_win_id)
    vim.cmd("startinsert")

    -- Notify the user
    vim.notify("Buffer content ready. Type your question about this file.", vim.log.levels.INFO)
  else
    -- Handle case where original buffer is no longer valid
    M.add_message("assistant", "Unable to retrieve buffer content. The original buffer may have been closed.")
  end
end

-- Get selection from line range (for commands called with range)
function M.get_selection_from_range(start_line, end_line)
  -- Get the selected lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Join the lines with newlines
  return table.concat(lines, '\n')
end

-- Ask about the current selection (supports range)
function M.ask_selection(opts)
  local selection = ""

  -- Get the selection either from the range or visual selection marks
  if opts.range > 0 then
    selection = M.get_selection_from_range(opts.line1, opts.line2)
  else
    selection = M.get_visual_selection()
  end

  -- Check if we have a valid selection
  if selection == "" then
    vim.notify("No text selected. Please select some code first.", vim.log.levels.WARN)
    return
  end

  -- Get filetype
  local filetype = M.get_current_filetype()

  -- Ensure the popup is open
  if not M.state.is_visible then
    M.create_popup()
  end

  -- Clear existing chat history for focused interaction
  M.clear_chat(true) -- silent clear

  -- Format as a prompt with code context
  local summary = config.code_prompts.custom.summary
  local full_prompt = config.code_prompts.custom.prompt .. "\n\n" ..
      M.format_code_context(selection, filetype)

  -- Show summary in chat
  M.add_message("assistant", summary)

  -- For custom queries, we show a helpful placeholder in the input box
  vim.api.nvim_buf_set_option(M.state.input_buf_id, "modifiable", true)
  vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, { "" })

  -- Set a placeholder that will be cleared when the user starts typing
  vim.fn.prompt_setprompt(M.state.input_buf_id, "")
  if vim.fn.exists("*setbuflinepre") == 1 then
    -- Modern Neovim version
    vim.api.nvim_set_option_value("buftype", "prompt", { buf = M.state.input_buf_id })
  else
    -- Older Neovim version
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "buftype", "prompt")
  end

  -- Display selected code as part of Claude's message
  M.state.chat_history[#M.state.chat_history].content = M.state.chat_history[#M.state.chat_history].content ..
  "\n\n" .. M.format_code_context(selection, filetype)
  M.display_chat_history()

  -- Focus the input window for editing
  vim.api.nvim_set_current_win(M.state.input_win_id)
  vim.cmd("startinsert")

  -- Store a reference to the selected code for message formatting
  M.state.selected_code = M.format_code_context(selection, filetype)
  M.state.stored_custom_prompt = config.code_prompts.custom.prompt

  -- Notify the user
  vim.notify("Code selection ready. Type your question or press Enter to analyze.", vim.log.levels.INFO)
end

-- Direct API call without using the popup UI
function M.call_claude_api_directly(system_prompt, user_prompt, callback)
  -- Show a thinking/progress indicator
  local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local spinner_idx = 1
  local spinner_timer

  local status_buf = vim.api.nvim_create_buf(false, true)
  local status_win

  local function show_status()
    -- Calculate window dimensions
    local width = 30
    local height = 3
    local win_opts = {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      style = "minimal",
      border = "rounded",
      title = " Claude Thinking... "
    }

    status_win = vim.api.nvim_open_win(status_buf, false, win_opts)

    -- Set content
    vim.api.nvim_buf_set_lines(status_buf, 0, -1, false, {
      "",
      "  " .. spinner[spinner_idx] .. " Processing request..."
    })

    -- Start spinner animation
    spinner_timer = vim.loop.new_timer()
    spinner_timer:start(0, 100, vim.schedule_wrap(function()
      spinner_idx = (spinner_idx % #spinner) + 1
      if status_buf and vim.api.nvim_buf_is_valid(status_buf) then
        vim.api.nvim_buf_set_lines(status_buf, 1, 2, false, {
          "  " .. spinner[spinner_idx] .. " Processing request..."
        })
      else
        if spinner_timer then
          spinner_timer:stop()
          spinner_timer:close()
          spinner_timer = nil
        end
      end
    end))
  end

  local function hide_status()
    if spinner_timer then
      spinner_timer:stop()
      spinner_timer:close()
      spinner_timer = nil
    end

    if status_win and vim.api.nvim_win_is_valid(status_win) then
      vim.api.nvim_win_close(status_win, true)
      status_win = nil
    end

    if status_buf and vim.api.nvim_buf_is_valid(status_buf) then
      vim.api.nvim_buf_delete(status_buf, { force = true })
      status_buf = nil
    end
  end

  -- Show the thinking status window
  show_status()

  -- Get API key (reusing the existing function)
  local api_key = M.get_api_key()
  if not api_key then
    hide_status()
    vim.notify("API key not found", vim.log.levels.ERROR)
    return
  end

  -- Format messages for Claude API - use system as top-level parameter
  local formatted_messages = {
    { role = "user", content = user_prompt }
  }

  -- Prepare the request data
  local request_data = {
    model = config.api.model,
    max_tokens = config.api.max_tokens,
    temperature = config.api.temperature,
    system = system_prompt,
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

  -- Run the curl command in the background
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      hide_status()

      if exit_code ~= 0 then
        vim.notify("API request failed with exit code: " .. exit_code, vim.log.levels.ERROR)
        return
      end

      -- Read response from temp file
      local file = io.open(temp_file, "r")
      if not file then
        vim.notify("Failed to read API response", vim.log.levels.ERROR)
        return
      end

      local response = file:read("*all")
      file:close()
      os.remove(temp_file)

      -- Parse JSON response
      local ok, parsed = pcall(vim.fn.json_decode, response)
      if not ok or not parsed then
        vim.notify("Failed to parse API response", vim.log.levels.ERROR)
        return
      end

      -- Check for API errors
      if parsed.error then
        vim.notify("API error: " .. (parsed.error.message or "Unknown error"), vim.log.levels.ERROR)
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

-- Replace code in buffer with Claude's output
function M.inline_code_replacement(start_line, end_line, selection, filetype, action_type, custom_prompt)
  -- Define fallback system prompts for all action types
  local fallback_system_prompts = {
    improve =
    "You are an expert programmer tasked with improving code. Focus on readability, performance, and best practices. Maintain the same functionality. Return ONLY the improved code WITHOUT explanations, comments about changes, markdown formatting, or code block indicators. The output should be plain code that can be directly inserted into the file.",

    implement =
    "You are an expert programmer tasked with implementing code based on comments or specifications. Write clean, efficient code following best practices. Return ONLY the implemented code WITHOUT explanations, markdown formatting, or code block indicators. The output should be plain code that can be directly inserted into the file.",

    implement_comment =
    "You are an expert programmer tasked with implementing code based on comments or specifications. Write clean, efficient code following best practices. Return ONLY the implemented code WITHOUT explanations, markdown formatting, or code block indicators. The output should be plain code that can be directly inserted into the file."
  }

  -- Get appropriate system prompt with fallback
  local system_prompt = fallback_system_prompts[action_type]

  if not system_prompt then
    -- Default system prompt for any action type
    system_prompt =
    "You are an expert programmer tasked with modifying code. Return ONLY the code without any explanations, markdown formatting, or code block indicators. The output should be plain code that can be directly inserted into the file."
  end

  -- Create user prompt
  local user_prompt

  if custom_prompt then
    -- Use the enhanced prompt if provided
    user_prompt = custom_prompt .. "\n\nHere is the " .. filetype .. " code:\n\n" .. selection ..
        "\n\nReturn ONLY the code without explanations, markdown formatting or code block backticks."
  else
    -- Fallback to basic prompt
    user_prompt = "Here is " .. filetype .. " code to " .. action_type .. ". Return ONLY the " ..
        action_type .. "d code without any explanations, just the plain code:\n\n" .. selection
  end

  -- We already have a valid system prompt from our fallbacks

  -- Call Claude API directly with the selected system prompt
  M.call_claude_api_directly(system_prompt, user_prompt, function(response)
    -- Clean any potential code block formatting from the response
    response = response:gsub("^```[%w_]*\n", ""):gsub("\n```$", "")

    -- Replace the code in the buffer
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, vim.split(response, "\n"))

    -- Notify the user of success
    vim.notify("Code successfully " .. action_type .. "d", vim.log.levels.INFO)
  end)
end

-- Perform a specific code action on the selection
function M.code_action(action_type)
  return function(opts)
    local selection = ""
    local start_line, end_line = 0, 0

    -- Get the selection either from the range or visual selection marks
    if opts.range > 0 then
      selection = M.get_selection_from_range(opts.line1, opts.line2)
      start_line = opts.line1
      end_line = opts.line2
    else
      -- Fallback to visual marks if range not provided
      start_line = vim.fn.line("'<")
      end_line = vim.fn.line("'>")
      selection = M.get_visual_selection()
    end

    -- Check if we have a valid selection
    if selection == "" then
      vim.notify("No text selected. Please select some code first.", vim.log.levels.WARN)
      return
    end

    -- Get filetype
    local filetype = M.get_current_filetype()

    -- For explain and analyze actions, use the popup with enhanced prompts
    if action_type == "explain" or action_type == "analyze" then
      -- Ensure the popup is open
      if not M.state.is_visible then
        M.create_popup()
      end

      -- Clear existing chat history for focused interaction
      M.clear_chat(true) -- silent clear

      -- Define emergency fallback prompts for common actions
      local fallback_prompts = {
        explain = {
          summary = "Explaining selected code...",
          prompt =
          "Please explain this code comprehensively:\n- Overall purpose and functionality\n- How each part contributes to the whole\n- Key algorithms or patterns used\n- Any non-obvious techniques or optimizations\n- Potential edge cases or limitations\n\nFormat your explanation clearly with sections and bullet points where appropriate:"
        },
        analyze = {
          summary = "Analyzing code for issues and improvements...",
          prompt =
          "Please analyze this code for:\n- Potential bugs or edge cases\n- Performance bottlenecks\n- Security vulnerabilities\n- Code smells or maintenance issues\n- Opportunities for simplification\n- Adherence to best practices\n\nOrganize your analysis by priority, focusing on the most important issues first:"
        },
        improve = {
          summary = "Improving selected code...",
          prompt =
          "As an expert programmer, please improve this code. Focus on:\n- Performance optimization\n- Better readability and code organization\n- Proper error handling and edge cases\n- Following language-specific best practices and idioms\n- Maintaining the original functionality\n\nProvide only the improved code without explanations unless there's something critical I should know:"
        },
        implement = {
          summary = "Implementing code from comments...",
          prompt =
          "Please implement code based on this comment/specification. Your implementation should:\n- Follow best practices for the language\n- Include appropriate error handling\n- Be well-structured and maintainable\n- Include helpful comments where needed\n- Be optimized for readability and performance\n\nProvide the complete implementation without explanations unless there are important design decisions to highlight:"
        },
        implement_comment = {
          summary = "Implementing code from comments...",
          prompt =
          "Please implement code based on this comment/specification. Your implementation should:\n- Follow best practices for the language\n- Include appropriate error handling\n- Be well-structured and maintainable\n- Include helpful comments where needed\n- Be optimized for readability and performance\n\nProvide the complete implementation without explanations unless there are important design decisions to highlight:"
        }
      }

      -- Get the appropriate prompt using the fallback if needed
      local prompt_info = fallback_prompts[action_type]

      -- If it's available in config, use that instead
      if config.code_prompts and config.code_prompts[action_type] and
          type(config.code_prompts[action_type]) == "table" and
          config.code_prompts[action_type].summary and
          config.code_prompts[action_type].prompt then
        prompt_info = config.code_prompts[action_type]
      end

      -- Make sure we have valid prompt info
      if not prompt_info then
        vim.notify("Error: No valid prompt for action type '" .. action_type .. "'", vim.log.levels.ERROR)
        return
      end

      -- Show summary in chat first
      M.add_message("assistant", prompt_info.summary)

      -- Format the complete prompt (for sending to API)
      local full_prompt = prompt_info.prompt .. "\n\n" .. M.format_code_context(selection, filetype)

      -- For specialized commands, we'll skip displaying user input and just send to API

      -- Show thinking indicator
      M.add_thinking_indicator()

      -- Send directly to API without displaying user prompt
      M.send_to_claude_silently(full_prompt, function(response)
        -- Remove thinking indicator
        M.remove_thinking_indicator()

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
    else
      -- For improve and implement actions, replace the code inline
      -- Define fallback prompts for inline replacements
      local fallback_prompts = {
        improve = {
          summary = "Improving selected code...",
          prompt =
          "As an expert programmer, please improve this code. Focus on:\n- Performance optimization\n- Better readability and code organization\n- Proper error handling and edge cases\n- Following language-specific best practices and idioms\n- Maintaining the original functionality\n\nProvide only the improved code without explanations unless there's something critical I should know:"
        },
        implement = {
          summary = "Implementing code from comments...",
          prompt =
          "Please implement code based on this comment/specification. Your implementation should:\n- Follow best practices for the language\n- Include appropriate error handling\n- Be well-structured and maintainable\n- Include helpful comments where needed\n- Be optimized for readability and performance\n\nProvide the complete implementation without explanations unless there are important design decisions to highlight:"
        },
        implement_comment = {
          summary = "Implementing code from comments...",
          prompt =
          "Please implement code based on this comment/specification. Your implementation should:\n- Follow best practices for the language\n- Include appropriate error handling\n- Be well-structured and maintainable\n- Include helpful comments where needed\n- Be optimized for readability and performance\n\nProvide the complete implementation without explanations unless there are important design decisions to highlight:"
        }
      }

      -- Get prompt info with fallback
      local prompt_info = fallback_prompts[action_type]

      -- If it's available in config, use that instead
      if config.code_prompts and config.code_prompts[action_type] and
          type(config.code_prompts[action_type]) == "table" and
          config.code_prompts[action_type].summary and
          config.code_prompts[action_type].prompt then
        prompt_info = config.code_prompts[action_type]
      end

      -- Make sure we have valid prompt info
      if not prompt_info then
        vim.notify("Error: No valid prompt for action type '" .. action_type .. "'", vim.log.levels.ERROR)
        return
      end

      -- Notify the user with a better message
      vim.notify(prompt_info.summary, vim.log.levels.INFO)

      -- Use enhanced prompts for better results
      M.inline_code_replacement(start_line, end_line, selection, filetype, action_type, prompt_info.prompt)
    end
  end
end

-- ============================================================================
-- UI Functions
-- ============================================================================

-- Create the Claude popup window
function M.create_popup()
  -- Calculate base dimensions
  local width = math.floor(vim.o.columns * config.ui.width)
  local total_height = math.floor(vim.o.lines * config.ui.height)

  -- Calculate content height with padding
  local content_height = math.floor(total_height * 0.8) -- Use 80% of height for content
  local input_height = 3
  local padding = 1                                     -- Add a line of padding between windows

  -- Calculate window positions
  local total_used_height = content_height + padding + input_height + 2 -- +2 for both borders
  local row = math.floor((vim.o.lines - total_used_height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create buffer if it doesn't exist
  if not M.state.buf_id or not vim.api.nvim_buf_is_valid(M.state.buf_id) then
    M.state.buf_id = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
    vim.api.nvim_buf_set_option(M.state.buf_id, "buftype", "nofile")
    vim.api.nvim_buf_set_option(M.state.buf_id, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(M.state.buf_id, "swapfile", false)
    vim.api.nvim_buf_set_option(M.state.buf_id, "filetype", "markdown")
    vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", false)
    vim.api.nvim_buf_set_option(M.state.buf_id, "readonly", true)

    -- Enable syntax highlighting
    vim.cmd("syntax enable")
  end

  -- Use the content height, input height, and padding calculated above

  -- Create window for the popup content
  M.state.win_id = vim.api.nvim_open_win(M.state.buf_id, true, {
    relative = "editor",
    width = width,
    height = content_height,
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

  -- Enable mouse support for scrolling
  vim.api.nvim_win_set_option(M.state.win_id, "mouse", "a")

  -- Create input buffer
  if not M.state.input_buf_id or not vim.api.nvim_buf_is_valid(M.state.input_buf_id) then
    M.state.input_buf_id = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "buftype", "nofile")
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(M.state.input_buf_id, "swapfile", false)
  end

  -- Create input window with proper spacing below content window
  M.state.input_win_id = vim.api.nvim_open_win(M.state.input_buf_id, false, {
    relative = "editor",
    width = width,
    height = input_height,
    row = row + content_height + padding + 1, -- Add extra space for border + padding
    col = col,
    border = config.ui.border,
    title = " Message ",
    style = "minimal",
    zindex = 50,
  })

  -- Set input window options
  vim.api.nvim_win_set_option(M.state.input_win_id, "wrap", true)
  vim.api.nvim_win_set_option(M.state.input_win_id, "cursorline", false)

  -- Set local keymaps for the main content window
  local content_window_maps = {
    [config.keymaps.clear] = "lua require('claude-popup').clear_chat()",
    ["<Esc>"] = "lua require('claude-popup').return_to_input()",
    ["<C-[>"] = "lua require('claude-popup').return_to_input()",
    ["i"] = "lua require('claude-popup').return_to_input()",
    ["v"] = "v", -- Allow visual mode for selection
    ["V"] = "V", -- Allow visual line mode for selection
    [config.keymaps.toggle] = "lua require('claude-popup').toggle_popup()",
    -- Scrolling keymaps
    ["j"] = "j",
    ["k"] = "k",
    ["<Down>"] = "j",
    ["<Up>"] = "k",
    ["<C-d>"] = "<C-d>",
    ["<C-u>"] = "<C-u>",
    ["<C-f>"] = "<C-f>",
    ["<C-b>"] = "<C-b>",
    ["G"] = "G",
    ["gg"] = "gg",
  }

  -- Set keymaps for the input window
  local input_window_maps = {
    [config.keymaps.clear] = "lua require('claude-popup').clear_chat()",
    ["<Esc>"] = "lua require('claude-popup').toggle_popup()",
    ["<C-[>"] = "lua require('claude-popup').toggle_popup()",
    [config.keymaps.toggle] = "lua require('claude-popup').toggle_popup()",
    -- Scrolling from input window
    ["<C-k>"] = "lua require('claude-popup').scroll_content('up')",
    ["<C-j>"] = "lua require('claude-popup').scroll_content('down')",
    ["<C-u>"] = "lua require('claude-popup').scroll_content('halfpage_up')",
    ["<C-d>"] = "lua require('claude-popup').scroll_content('halfpage_down')",
    ["<C-b>"] = "lua require('claude-popup').scroll_content('page_up')",
    ["<C-f>"] = "lua require('claude-popup').scroll_content('page_down')",
    ["<C-g><C-g>"] = "lua require('claude-popup').scroll_content('top')",
    ["<C-g>g"] = "lua require('claude-popup').scroll_content('bottom')",
    -- Focus content window for copy/selection (using Ctrl-y as it's less commonly used)
    ["<C-y>"] = "<Esc>:lua require('claude-popup').focus_content_window()<CR>",
  }

  -- Apply keymaps to content window
  for key, cmd in pairs(content_window_maps) do
    if key then
      -- For movement commands, map them directly without wrapping in command mode
      if cmd == "j" or cmd == "k" or cmd == "G" or cmd == "gg" or
          cmd == "<C-d>" or cmd == "<C-u>" or cmd == "<C-f>" or cmd == "<C-b>" or
          cmd == "v" or cmd == "V" then
        vim.api.nvim_buf_set_keymap(M.state.buf_id, "n", key, cmd, { noremap = true, silent = true })
      else
        -- For functions calls, use command mode
        vim.api.nvim_buf_set_keymap(M.state.buf_id, "n", key, ":" .. cmd .. "<CR>", { noremap = true, silent = true })
      end
    end
  end

  -- Apply keymaps to input window
  for key, cmd in pairs(input_window_maps) do
    if key then
      -- For Ctrl+Y content focus shortcut
      if key == "<C-y>" then
        -- Apply it directly without modification in normal mode
        vim.api.nvim_buf_set_keymap(M.state.input_buf_id, "n", key, cmd, { noremap = true, silent = true })
        -- And in insert mode
        vim.api.nvim_buf_set_keymap(M.state.input_buf_id, "i", key, cmd, { noremap = true, silent = true })
      else
        -- Input window (normal mode)
        vim.api.nvim_buf_set_keymap(M.state.input_buf_id, "n", key, ":" .. cmd .. "<CR>",
          { noremap = true, silent = true })

        -- Also make scrolling commands available in insert mode
        if key:match("^<C%-%a>$") or key:match("^<C%-[dfubkj]>$") or key:match("^<C%-g>") then
          vim.api.nvim_buf_set_keymap(M.state.input_buf_id, "i", key, "<Esc>:" .. cmd .. "<CR>a",
            { noremap = true, silent = true })
        end
      end
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
  local display_message = table.concat(lines, "\n")

  -- Check if it's okay to send an empty message
  if display_message:match("^%s*$") and not (M.state.selected_code and M.state.stored_custom_prompt) then
    vim.notify("Cannot send empty message", vim.log.levels.WARN)
    return
  end

  -- Clear the input buffer
  vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, { "" })

  -- Add the display message to the chat
  M.add_message("user", display_message)

  -- Determine the actual message to send to the API
  local api_message = display_message

  -- If we have selected code and custom prompt (from ask_selection), format a complete prompt
  if M.state.selected_code and M.state.stored_custom_prompt then
    -- Format a complete prompt with the selected code and custom question
    api_message = M.state.stored_custom_prompt .. "\n\n" ..
        M.state.selected_code .. "\n\n"

    -- Only add user question if they actually wrote something
    if display_message and display_message:match("%S") then
      api_message = api_message .. "User question: " .. display_message
    end

    -- Clear stored values so we don't reuse them
    M.state.selected_code = nil
    M.state.stored_custom_prompt = nil
  end

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

  -- Prepare messages for the API - with special handling for the last user message
  local api_messages = {}

  -- Copy all but the last message
  for i = 1, #M.state.chat_history - 1 do
    table.insert(api_messages, M.state.chat_history[i])
  end

  -- Add the real API message instead of what's displayed
  table.insert(api_messages, {
    role = "user",
    content = api_message
  })

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

-- Submit a message but display a different version in the chat
-- This allows sending detailed prompts to the API while showing simpler versions in the UI
function M.submit_message_with_display(display_message)
  -- Don't submit if we're already waiting for a response
  if M.state.waiting_response then
    vim.notify("Claude is still thinking...", vim.log.levels.INFO)
    return
  end

  -- Get the actual message to send from the input buffer
  local lines = vim.api.nvim_buf_get_lines(M.state.input_buf_id, 0, -1, false)
  local api_message = table.concat(lines, "\n")

  -- Don't submit empty messages
  if api_message:match("^%s*$") then
    vim.notify("Cannot send empty message", vim.log.levels.WARN)
    return
  end

  -- Clear the input buffer
  vim.api.nvim_buf_set_lines(M.state.input_buf_id, 0, -1, false, { "" })

  -- Add the display version to the chat history
  M.add_message("user", display_message)

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

  -- Prepare messages for the API - replace the last user message
  local api_messages = {}

  -- Copy all but the last message
  for i = 1, #M.state.chat_history - 1 do
    table.insert(api_messages, M.state.chat_history[i])
  end

  -- Add the real API message instead of the display message
  table.insert(api_messages, {
    role = "user",
    content = api_message
  })

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

-- Send to Claude API silently (no user message displayed)
function M.send_to_claude_silently(prompt, callback)
  -- Don't submit if we're already waiting for a response
  if M.state.waiting_response then
    vim.notify("Claude is still thinking...", vim.log.levels.INFO)
    return
  end

  -- Create a message for the API without displaying it in UI
  local user_message = {
    role = "user",
    content = prompt
  }

  -- Prepare messages for the API (all previous messages plus the hidden one)
  local api_messages = {}

  -- Add all existing messages
  for _, msg in ipairs(M.state.chat_history) do
    table.insert(api_messages, msg)
  end

  -- Add the hidden user message
  table.insert(api_messages, user_message)

  -- Keep focus in the input window while waiting for response
  if M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
    vim.api.nvim_set_current_win(M.state.input_win_id)
  end

  -- Send to Claude API
  M.send_to_claude(api_messages, callback)
end

-- Add a message to the chat
function M.add_message(role, content)
  -- Validate inputs to avoid errors
  if not role then
    vim.notify("Error: role is nil in add_message", vim.log.levels.ERROR)
    role = "assistant"
  end

  if not content then
    vim.notify("Error: content is nil in add_message", vim.log.levels.ERROR)
    content = "[No content provided]"
  end

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
    -- Make sure content is a string to avoid errors
    if msg.content == nil then
      msg.content = "[No content]"
    end

    local content_lines = vim.split(tostring(msg.content), "\n")
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
  vim.api.nvim_buf_set_option(M.state.buf_id, "readonly", false)
  vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", true)
  vim.api.nvim_buf_set_lines(M.state.buf_id, 0, -1, false, display_lines)
  vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", false)
  vim.api.nvim_buf_set_option(M.state.buf_id, "readonly", true)

  -- Apply highlighting
  M.apply_highlighting()

  -- Apply Markdown syntax highlighting
  vim.api.nvim_buf_set_option(M.state.buf_id, "syntax", "markdown")

  -- Make sure code blocks are highlighted properly
  local ns_id = vim.api.nvim_create_namespace("claude_popup_syntax")

  -- Refresh the highlighting without changing the buffer
  vim.api.nvim_buf_set_option(M.state.buf_id, "syntax", "")
  vim.api.nvim_buf_set_option(M.state.buf_id, "syntax", "markdown")

  -- Scroll to the bottom, but don't center view (allowing scrolling)
  if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
    local line_count = #display_lines
    -- Only set cursor if there are actually lines in the buffer
    if line_count > 0 then
      vim.api.nvim_win_set_cursor(M.state.win_id, { line_count, 0 })
      -- Don't center with zz to enable scrolling through history
    end
  end

  -- Return focus to input window if we were waiting for a response
  if M.state.waiting_response and M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
    vim.api.nvim_set_current_win(M.state.input_win_id)
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

  -- Don't add another thinking indicator if one is already active
  if M.state.thinking_indicator_active then
    return
  end

  -- Mark that a thinking indicator is active
  M.state.thinking_indicator_active = true

  -- Check if we have a last assistant message to update
  local last_index = #M.state.chat_history

  if last_index > 0 and M.state.chat_history[last_index].role == "assistant" then
    -- Store original content for later restoration
    local original_content = M.state.chat_history[last_index].content
    M.state.original_assistant_message = original_content

    -- Update the message to show thinking status
    M.state.chat_history[last_index].content = original_content .. "\n\n*Thinking...*"

    -- Redisplay with updated content which will apply markdown syntax
    M.display_chat_history()
  else
    -- No suitable message to update, add a new thinking message
    -- Add thinking indicator to buffer
    vim.api.nvim_buf_set_option(M.state.buf_id, "readonly", false)
    vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", true)

    local lines = vim.api.nvim_buf_get_lines(M.state.buf_id, 0, -1, false)
    table.insert(lines, "")
    table.insert(lines, "Claude: ")
    table.insert(lines, "*Thinking...*")

    vim.api.nvim_buf_set_lines(M.state.buf_id, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", false)
    vim.api.nvim_buf_set_option(M.state.buf_id, "readonly", true)

    -- Highlight the thinking text
    local ns_id = vim.api.nvim_create_namespace("claude_popup_thinking")
    vim.api.nvim_buf_add_highlight(M.state.buf_id, ns_id, config.ui.colors.thinking, #lines - 1, 0, -1)

    -- Ensure syntax highlighting is applied
    vim.api.nvim_buf_set_option(M.state.buf_id, "syntax", "markdown")

    -- Scroll to show the thinking indicator
    if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
      vim.api.nvim_win_set_cursor(M.state.win_id, { #lines, 0 })
    end
  end
end

-- Remove the thinking indicator
function M.remove_thinking_indicator()
  if not M.state.buf_id or not vim.api.nvim_buf_is_valid(M.state.buf_id) then
    return
  end

  -- Reset the thinking indicator flag
  M.state.thinking_indicator_active = false

  -- Restore original message if we modified one
  if M.state.original_assistant_message then
    -- Find the last assistant message
    local last_index = #M.state.chat_history

    if last_index > 0 and M.state.chat_history[last_index].role == "assistant" then
      -- Restore original content
      M.state.chat_history[last_index].content = M.state.original_assistant_message
    end

    -- Clear the stored message
    M.state.original_assistant_message = nil
  end

  -- Redisplay without the indicator
  M.display_chat_history()
end

-- Show an error message
function M.show_error(message)
  -- Display error in the popup if it exists
  if M.state.buf_id and vim.api.nvim_buf_is_valid(M.state.buf_id) then
    vim.api.nvim_buf_set_option(M.state.buf_id, "readonly", false)
    vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", true)

    local lines = vim.api.nvim_buf_get_lines(M.state.buf_id, 0, -1, false)
    table.insert(lines, "")
    table.insert(lines, "Error: " .. message)

    vim.api.nvim_buf_set_lines(M.state.buf_id, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(M.state.buf_id, "modifiable", false)
    vim.api.nvim_buf_set_option(M.state.buf_id, "readonly", true)

    -- Highlight the error text
    local ns_id = vim.api.nvim_create_namespace("claude_popup_error")
    vim.api.nvim_buf_add_highlight(M.state.buf_id, ns_id, config.ui.colors.error, #lines - 1, 0, -1)
  else
    -- Otherwise use vim.notify
    vim.notify("Claude AI Error: " .. message, vim.log.levels.ERROR)
  end
end

-- Clear the chat history
function M.clear_chat(silent)
  -- Clear the history
  M.state.chat_history = {}

  -- Update the display
  M.display_chat_history()

  -- Add initial message if configured and not in silent mode
  if config.chat.initial_message and not silent then
    M.add_message("assistant", config.chat.initial_message)
  end
end

-- Window management and scrolling functions --

-- Switch focus to the content window (for copying/selecting text)
function M.focus_content_window()
  if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
    vim.api.nvim_set_current_win(M.state.win_id)
    -- Show a subtle indication that we're in selection mode
    vim.api.nvim_win_set_option(M.state.win_id, "cursorline", true)
    -- Use a statusline message instead of colorcolumn
    vim.api.nvim_win_set_option(M.state.win_id, "statusline", "-- CONTENT VIEW MODE: ESC or 'i' to return to input --")
    vim.notify("Content window focused. Press ESC or 'i' to return to input box.", vim.log.levels.INFO)
  end
end

-- Return focus to the input window
function M.return_to_input()
  -- Disable visual indicators in content window
  if M.state.win_id and vim.api.nvim_win_is_valid(M.state.win_id) then
    vim.api.nvim_win_set_option(M.state.win_id, "cursorline", false)
    vim.api.nvim_win_set_option(M.state.win_id, "statusline", "")
  end

  -- Focus input window and enter insert mode
  if M.state.input_win_id and vim.api.nvim_win_is_valid(M.state.input_win_id) then
    vim.api.nvim_set_current_win(M.state.input_win_id)
    vim.cmd("startinsert")
  end
end

-- Scroll the content window without changing input focus
function M.scroll_content(direction)
  if not M.state.win_id or not vim.api.nvim_win_is_valid(M.state.win_id) then
    return
  end

  -- Store current window to restore focus
  local current_win = vim.api.nvim_get_current_win()

  -- Focus content window temporarily
  vim.api.nvim_set_current_win(M.state.win_id)

  -- Perform scroll action based on direction
  if direction == "up" then
    vim.cmd("normal! 3k")
  elseif direction == "down" then
    vim.cmd("normal! 3j")
  elseif direction == "halfpage_up" then
    vim.cmd("normal! \x15") -- <C-u>
  elseif direction == "halfpage_down" then
    vim.cmd("normal! \x04") -- <C-d>
  elseif direction == "page_up" then
    vim.cmd("normal! \x02") -- <C-b>
  elseif direction == "page_down" then
    vim.cmd("normal! \x06") -- <C-f>
  elseif direction == "top" then
    vim.cmd("normal! gg")
  elseif direction == "bottom" then
    vim.cmd("normal! G")
  end

  -- Restore focus to original window
  vim.api.nvim_set_current_win(current_win)

  -- Maintain insert mode if we were in it
  if current_win == M.state.input_win_id and vim.api.nvim_get_mode().mode:match("^i") then
    vim.cmd("startinsert")
  end
end

-- Return the module
return M
