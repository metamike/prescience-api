TaxFormBuilder.constructify do
  form '1040d' do
    # Short-Term
    cell '1h', proc { short_term_capital_net }
    cell '4', 0
    cell '5', 0
    cell '6', 0   # TODO capital loss carryover from prior year
    cell '7', :net_short_term_capital_gain, proc { c1h + c4 + c5 + c6 }

    # Long-Term
    cell '8h', proc { long_term_capital_net }
    cell '11', 0
    cell '12', 0
    cell '13', 0
    cell '14', 0   # TODO capital loss carryover
    cell '15', :net_long_term_capital_gain, proc { c8h + c11 + c12 + c13 + c14 }

    # Summary
    cell '16', proc { c7 + c15 }
    cell '17', proc { c15 > 0 && c16 > 0 ? :yes : :no }
    cell '18', 0
    cell '19', 0
    cell '21', proc { [-tax_info.max_capital_loss_for_year(tax_year, filing_status), c16].max }
    cell '23', :capital_net, proc { c16 >= 0 ? c16 : c21 }
  end

  #
  # == WORKSHEETS ==
  #

  # Capital Loss Carryover
  form :capital_loss_carryover do
    cell '1', proc { prior_year_adjusted_gross_income - prior_year_itemized_deductions }
    cell '2', proc { -prior_year_capital_net }
    cell '3', proc { c1 + c2 >= 0 ? c1 + c2 : 0 }
    cell '4', proc { [c2, c3].min }
    # TODO Finish this
    cell '5', proc { -prior_year_short_term_capital_net }
  end
end
