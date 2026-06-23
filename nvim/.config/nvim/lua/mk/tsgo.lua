local M = {}

function M.apply_completion_range_workaround()
  if vim.g.tsgo_completion_range_workaround_applied then
    return
  end

  local completion = vim.lsp.completion
  local convert_results = completion._convert_results
  if type(convert_results) ~= 'function' then
    return
  end

  vim.g.tsgo_completion_range_workaround_applied = true

  completion._convert_results = function(
    line,
    lnum,
    cursor_col,
    client_id,
    client_start_boundary,
    server_start_boundary,
    result,
    encoding
  )
    local matches, start_boundary = convert_results(
      line,
      lnum,
      cursor_col,
      client_id,
      client_start_boundary,
      server_start_boundary,
      result,
      encoding
    )
    local client = vim.lsp.get_client_by_id(client_id)

    -- tsgo mixes a dot-replacing edit for `[Symbol]` with plain member
    -- completions. Neovim then uses that edit range for the entire list.
    -- https://github.com/neovim/neovim/discussions/38042
    if
      client
      and client.name == 'tsgo'
      and start_boundary
      and start_boundary < client_start_boundary
    then
      local missing_prefix = line:sub(start_boundary + 1, client_start_boundary)

      for _, match in ipairs(matches) do
        local item = vim.tbl_get(
          match,
          'user_data',
          'nvim',
          'lsp',
          'completion_item'
        )
        if
          item
          and not item.textEdit
          and not vim.startswith(match.word, missing_prefix)
        then
          match.word = missing_prefix .. match.word
        end
      end
    end

    return matches, start_boundary
  end
end

return M
