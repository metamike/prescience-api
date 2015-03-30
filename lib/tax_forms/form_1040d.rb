TaxFormBuilder.constructify do
  form '1040d' do
    cell '1ad', proc { short_term_proceeds  }
  end
end
