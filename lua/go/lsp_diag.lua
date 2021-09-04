-- hdlr alternatively, use lua vim.lsp.diagnostic.set_loclist({open_loclist = false})
-- true to open loclist
-- local diag_hdlr = function(err, method, result, client_id, bufnr, config)
-- New signature on_publish_diagnostics({_}, {result}, {ctx}, {config})
debug = debug or nil
local nvim_0_6 = false
if debug.getinfo(vim.lsp.handlers["textDocument/publishDiagnostics"]).nparams == 4 then
  nvim_0_6 = true
end

local function hdlr(result)
  if result and result.diagnostics then
    local item_list = {}
    local s = result.uri
    local fname = s
    for _, v in ipairs(result.diagnostics) do
      local i, j = string.find(s, "file://")
      if j then
        fname = string.sub(s, j + 1)
      end
      table.insert(item_list, {
        filename = fname,
        lnum = v.range.start.line + 1,
        col = v.range.start.character + 1,
        text = v.message
      })
    end
    local old_items = vim.fn.getqflist()
    for _, old_item in ipairs(old_items) do
      if vim.uri_from_bufnr(old_item.bufnr) ~= result.uri then
        table.insert(item_list, old_item)
      end
    end
    vim.fn.setqflist({}, ' ', {title = 'LSP', items = item_list})
  end
end
local diag_hdlr_0_5 = function(err, result, ctx, config)
  -- vim.lsp.diagnostic.clear(vim.fn.bufnr(), client.id, nil, nil)
  vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
  hdlr(result)
end

local diag_hdlr_0_6 = function(err, result, ctx, config)
  -- vim.lsp.diagnostic.clear(vim.fn.bufnr(), client.id, nil, nil)
  vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
  hdlr(result)
end

local diag_hdlr = diag_hdlr_0_5
if nvim_0_6 then
  diag_hdlr = diag_hdlr_0_6
end

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(diag_hdlr, {
      -- Enable underline, use default values
      underline = true,
      -- Enable virtual text, override spacing to 0
      virtual_text = {
        spacing = 0,
        prefix = '' -- '',  
      },
      -- Use a function to dynamically turn signs off
      -- and on, using buffer local variables
      signs = true,
      -- Disable a feature
      update_in_insert = false
    })
