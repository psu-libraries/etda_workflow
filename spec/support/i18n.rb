# Allow us to use t('key') instead of I18n.t('key')
def t(symbol, options = {})
  I18n.t(symbol, options)
end
