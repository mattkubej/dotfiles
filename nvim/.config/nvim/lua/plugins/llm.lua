return {
  {
    dir = '~/.config/nvim/lua/local-plugins/llm.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local system_prompt =
      'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
      local helpful_prompt =
      'You are a helpful assistant. What I have sent are my notes so far. You are very curt, yet helpful.'
      local llm = require('llm')

      local function anthropic_help()
        llm.invoke_llm_and_stream_into_editor({
          url = 'LLM_PROXY',
          model = 'anthropic:claude-3-7-sonnet',
          api_key_name = 'OPENAI_API_KEY',
          system_prompt = helpful_prompt,
          replace = false,
        }, llm.make_spec_curl_args, llm.handle_spec_data)
      end

      local function anthropic_replace()
        llm.invoke_llm_and_stream_into_editor({
          url = 'LLM_PROXY',
          model = 'anthropic:claude-3-7-sonnet',
          api_key_name = 'OPENAI_API_KEY',
          system_prompt = system_prompt,
          replace = true,
        }, llm.make_spec_curl_args, llm.handle_spec_data)
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>L', anthropic_help, { desc = 'llm anthropic_help' })
      vim.keymap.set({ 'n', 'v' }, '<leader>l', anthropic_replace, { desc = 'llm anthropic' })
    end,
  },
  {
    dir = '~/.config/nvim/lua/local-plugins/claude-popup.nvim',
    config = function()
      require('claude-popup').setup({
        keymaps = {
          toggle = "<leader>cc",         -- Toggle Claude popup visibility
          submit = "<C-s>",              -- Submit a message in insert mode
          clear = "<C-l>",               -- Clear the chat history
          ask_buffer = "<leader>cb",     -- Ask about current buffer
          ask_selection = "<leader>cs",  -- Ask about selected code
          improve_selection = "<leader>ci", -- Ask Claude to improve selected code
          explain_selection = "<leader>ce",  -- Ask Claude to explain selected code
          implement_comment = "<leader>cp", -- Ask Claude to implement code from comment
        },
        ui = {
          width = 0.7,           -- Width as percentage of screen
          height = 0.6,          -- Height as percentage of screen
          border = "rounded",    -- Border style
          title = " Claude AI (Enter=submit in normal mode, C-s=submit in insert) ",  -- Remind user how to use
        },
        chat = {
          save_history = true,   -- Save chat history between sessions
          initial_message = "Hello! I'm Claude. Here's how to use this chat:\n\n• Type your message and press Enter in normal mode to submit\n• Use C-s in insert mode to submit\n• Press Esc to exit insert mode, then use <leader>cc to toggle the window\n• Use <leader>cs in visual mode to send selected code\n• Use <leader>ce to explain selected code\n• Use <leader>ci to improve selected code\n• Use <leader>cp to implement code from comments",
        },
        code_prompts = {
          improve = "Please improve this code. Consider performance, readability, error handling, and best practices:",
          explain = "Please explain what this code does in detail:",
          implement = "Please implement code based on this comment/specification:",
          analyze = "Please analyze this code for potential issues, bugs, or improvements:",
        }
      })
    end
  }
}
