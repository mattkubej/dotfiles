local M = {}
local Job = require 'plenary.job'

-- Load token provider
local ok, token_provider = pcall(require, 'token_provider')
if not ok then
  vim.notify("Failed to load token provider.", vim.log.levels.ERROR)
  token_provider = {
    get_token = function(callback)
      vim.schedule(function()
        vim.notify("Token provider not implemented", vim.log.levels.ERROR)
      end)
      callback(nil)
    end
  }
end

-- Original LLM functionality
function M.get_lines_until_cursor()
  local current_buffer = vim.api.nvim_get_current_buf()
  local current_window = vim.api.nvim_get_current_win()
  local cursor_position = vim.api.nvim_win_get_cursor(current_window)
  local row = cursor_position[1]

  local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, row, true)

  return table.concat(lines, '\n')
end

function M.get_visual_selection()
  local _, srow, scol = unpack(vim.fn.getpos 'v')
  local _, erow, ecol = unpack(vim.fn.getpos '.')

  if vim.fn.mode() == 'V' then
    if srow > erow then
      return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
    else
      return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
    end
  end

  if vim.fn.mode() == 'v' then
    if srow < erow or (srow == erow and scol <= ecol) then
      return vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
    else
      return vim.api.nvim_buf_get_text(0, erow - 1, ecol - 1, srow - 1, scol, {})
    end
  end

  if vim.fn.mode() == '\22' then
    local lines = {}
    if srow > erow then
      srow, erow = erow, srow
    end
    if scol > ecol then
      scol, ecol = ecol, scol
    end
    for i = srow, erow do
      table.insert(lines,
        vim.api.nvim_buf_get_text(0, i - 1, math.min(scol - 1, ecol), i - 1, math.max(scol - 1, ecol), {})[1])
    end
    return lines
  end
end

function M.make_spec_curl_args(opts, prompt, system_prompt)
  local url = opts.url and os.getenv(opts.url)
  local api_key = opts.api_key or (opts.api_key_name and os.getenv(opts.api_key_name))
  local data = {
    messages = { { role = 'system', content = system_prompt }, { role = 'user', content = prompt } },
    model = opts.model,
    stream = true,
  }
  local args = { '-N', '-X', 'POST', '-H', 'Content-Type: application/json', '-d', vim.json.encode(data) }
  if api_key then
    table.insert(args, '-H')
    table.insert(args, 'Authorization: Bearer ' .. api_key)
  end
  table.insert(args, url)
  return args
end

function M.write_string_at_cursor(str)
  vim.schedule(function()
    local current_window = vim.api.nvim_get_current_win()
    local cursor_position = vim.api.nvim_win_get_cursor(current_window)
    local row, col = cursor_position[1], cursor_position[2]

    local lines = vim.split(str, '\n')

    vim.cmd("undojoin")
    vim.api.nvim_put(lines, 'c', true, true)

    local num_lines = #lines
    local last_line_length = #lines[num_lines]
    vim.api.nvim_win_set_cursor(current_window, { row + num_lines - 1, col + last_line_length })
  end)
end

local function get_prompt(opts)
  local replace = opts.replace
  local visual_lines = M.get_visual_selection()
  local prompt = ''

  if visual_lines then
    prompt = table.concat(visual_lines, '\n')
    if replace then
      vim.api.nvim_command 'normal! d'
      vim.api.nvim_command 'normal! k'
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', false, true, true), 'nx', false)
    end
  else
    prompt = M.get_lines_until_cursor()
  end

  return prompt
end

function M.handle_spec_data(data_stream)
  if data_stream:match '"delta":' then
    local json = vim.json.decode(data_stream)
    if json.choices and json.choices[1] and json.choices[1].delta then
      local content = json.choices[1].delta.content
      if content then
        M.write_string_at_cursor(content)
      end
    end
  end
end

local group = vim.api.nvim_create_augroup('LLM_AutoGroup', { clear = true })
local active_job = nil

function M.invoke_llm_and_stream_into_editor(opts, make_curl_args_fn, handle_data_fn)
  vim.schedule(function()
    vim.api.nvim_clear_autocmds { group = group }
  end)
  local prompt = get_prompt(opts)
  local system_prompt = opts.system_prompt or 'Yell at me for not setting my configuration for my llm plugin correctly'
  local args = make_curl_args_fn(opts, prompt, system_prompt)
  local curr_event_state = nil

  local function parse_and_call(line)
    local event = line:match '^event: (.+)$'
    if event then
      curr_event_state = event
      return
    end
    local data_match = line:match '^data: (.+)$'
    if data_match then
      handle_data_fn(data_match, curr_event_state)
    end
  end

  if active_job then
    active_job:shutdown()
    active_job = nil
  end

  active_job = Job:new {
    command = 'curl',
    args = args,
    on_stdout = function(_, out)
      parse_and_call(out)
    end,
    on_stderr = function(_, _) end,
    on_exit = function()
      active_job = nil
    end,
  }

  active_job:start()

  vim.schedule(function()
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'LLM_Escape',
      callback = function()
        if active_job then
          active_job:shutdown()
          print 'LLM streaming cancelled'
          active_job = nil
        end
      end,
    })

    vim.api.nvim_set_keymap('n', '<Esc>', ':doautocmd User LLM_Escape<CR>', { noremap = true, silent = true })
  end)

  return active_job
end

-- New function that uses the token manager
function M.invoke_llm_with_token(opts, make_curl_args_fn, handle_data_fn)
  vim.schedule(function()
    vim.api.nvim_clear_autocmds { group = group }
  end)
  local prompt = get_prompt(opts)
  local system_prompt = opts.system_prompt or 'Yell at me for not setting my configuration for my llm plugin correctly'

  token_provider.get_token(function(token)
    if not token then
      vim.schedule(function()
        vim.notify("Failed to get LLM token", vim.log.levels.ERROR)
      end)
      return
    end

    -- Set the token in opts
    opts.api_key = token

    local args = make_curl_args_fn(opts, prompt, system_prompt)
    local curr_event_state = nil

    local function parse_and_call(line)
      local event = line:match '^event: (.+)$'
      if event then
        curr_event_state = event
        return
      end
      local data_match = line:match '^data: (.+)$'
      if data_match then
        handle_data_fn(data_match, curr_event_state)
      end
    end

    if active_job then
      active_job:shutdown()
      active_job = nil
    end

    active_job = Job:new {
      command = 'curl',
      args = args,
      on_stdout = function(_, out)
        parse_and_call(out)
      end,
      on_stderr = function(_, _) end,
      on_exit = function()
        active_job = nil
      end,
    }

    active_job:start()

    vim.schedule(function()
      vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = 'LLM_Escape',
        callback = function()
          if active_job then
            active_job:shutdown()
            print 'LLM streaming cancelled'
            active_job = nil
          end
        end,
      })

      vim.api.nvim_set_keymap('n', '<Esc>', ':doautocmd User LLM_Escape<CR>', { noremap = true, silent = true })
    end)
  end)

  return active_job
end

return M
