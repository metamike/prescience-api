TaxFormBuilder.constructify do
  form '1040' do
    # Exemptions
    cell '6a', 1
    cell '6b', proc { filing_status == 'married' ? 1 : 0 }
    cell '6c', 0
    cell '6d', proc { c6a + c6b + c6c }
    # Income
    cell  '7',  proc { wages }
    cell  '8a', proc { taxable_interest }
    cell  '8b', 0
    cell  '9a', proc { taxable_dividends }
    cell  '9b', proc { qualified_dividends }
    cell '10',  proc { fstate_income_tax_refund_worksheet.c7 }
    cell '11',  0
    cell '12',  0
    cell '13',  proc { f1040d.capital_net }
    cell '14',  0
    cell '15a', 0   # TODO IRA Distributions
    cell '15b', 0   # TODO IRA Distributions
    cell '16a', 0
    cell '16b', 0
    cell '17',  0   # TODO Robin's house?
    cell '18',  0
    cell '19',  0
    cell '20a', 0   # TODO Social Security
    cell '20b', 0   # TODO Social Security
    cell '21',  0
    cell '22', :total_income, proc {
      [c7, c8a, c9a, c10, c11, c12, c13, c14, c15b, c16b, c17, c18, c19, c20b, c21].sum
    }
    # Adjusted Gross Income
    cell '23',  0
    cell '24',  0
    cell '25',  0
    cell '26',  0
    cell '27',  0
    cell '28',  0
    cell '29',  0
    cell '30',  0   # TODO IRA Withdrawal
    cell '31a', 0
    cell '32',  0   # TODO IRA Deduction
    cell '33',  0
    cell '34',  0
    cell '35',  0
    cell '36',  proc {
      [c23, c24, c25, c26, c27, c28, c29, c30, c31a, c32, c33, c34, c34].sum
    }
    cell '37', proc { c22 - c36 }
    # Tax and Credits
    cell '38', :adjusted_gross_income, proc { c37 }
    cell '40', proc {
      itemized = f1040a.itemized_deductions
      [itemized, standard_deduction_worksheet.standard_deduction].max
    }
    cell '41', proc { c38 - c40 }
    cell '42', :exemptions, proc { fexemptions_worksheet.deduction }
    cell '43', :taxable_income, proc { c42 <= c41 ? c41 - c42 : 0 }
    cell '44', :tax, proc { fqualified_dividends_and_capital_gain_tax_worksheet.tax }
    cell '45', :alternative_minimum_tax, proc { f6251.amt }
    cell '46', 0
    cell '47', proc { [c44, c45, c46].sum }
    cell '48', 0   # TODO Foreign Tax Credit
    cell '49', 0
    cell '50', 0
    cell '51', 0
    cell '52', 0
    cell '53', 0
    cell '54', 0
    cell '55', :total_credits, proc { [c48, c49, c50, c51, c52, c53, c54].sum }
    cell '56', proc { c47 > c55 ? c47 - c55 : 0 }
    # Other Taxes
    cell '57', 0
    cell '58', 0
    cell '59', 0   # TODO Additional IRA Taxes
    cell '60', 0
    cell '61', 0
    cell '62', 0
    cell '63'. :total_tax, proc { [c56, c57, c58, c59, c60, c61, c62].sum }
    # Payments
    cell '64', proc { federal_income_tax_withheld }
    cell '65', 0
    cell '66', 0
    cell '67', 0
    cell '68', 0
    cell '69', 0
    cell '70', 0
    cell '71', 0   # TODO Excess SS tax withheld
    cell '72', 0
    cell '73', 0
    cell '74', :total_payments, proc { [c64, c65, c66, c67, c68, c69, c70, c71, c72, c73].sum }
    # Net
    cell '78', :federal_income_tax_owed, proc { c63 - c74 }
  end

  #
  # == WORKSHEETS ==
  #

  # State Income Tax Refund
  form :state_income_tax_refund_worksheet do
    cell '1', proc { [state_income_tax_refund, prior_year_state_income_taxes].min }
    cell '2', proc { prior_year_itemized_deductions }
    cell '3', proc { tax_info.standard_deduction_for_year(tax_year - 1, filing_status) }
    cell '4', 0
    cell '5', proc { c3 + c4 }
    cell '6', proc { c5 < c2 ? c2 - c5 : :stop }
    cell '7', proc { c6 == :stop ? 0 : [c1, c6].min }
  end

  # Standard Deduction
  form :standard_deduction_worksheet do
    cell '1',  proc {
      earned_income = f1040.c7 + f1040.c12 + f1040.c18 - f1040.c27
      earned_income > 650 ? earned_income + 350 : 1000
    }
    cell '2',  proc { tax_info.standard_deduction(filing_status) }
    cell '3a', :standard_deduction, proc { [c1, c2].min }
  end

  # Deduction for Exemptions
  form :exemptions_worksheet do
    cell '1', proc { f1040.c38 > c4 ? :high_income : :low_income}
    cell '2', proc { f1040.6d * tax_info.personal_exemption }
    cell '3', proc { f1040.adjusted_gross_income }
    cell '4', proc { tax_info.personal_exemption_income_limit }
    cell '5', proc { c3 - c4 > 122500 ? :stop : c3 - c4 }
    cell '6', proc { (c5 / 2500).ceil }
    cell '7', proc { (c6 * 0.02).round(2) }
    cell '8', proc { c2 * c7 }
    cell '9', :deduction, proc {
      if c1 == :low_income
        tax_info.personal_exemption * f1040.c6d
      else
        c5 == :stop ? 0 : c2 - c8
      end
    }
  end

  # Qualified Dividends and Capital Gain Tax Worksheet
  form :qualified_dividends_and_capital_gain_tax_worksheet do
    cell  '1', proc { f1040.taxable_income }
    cell  '2', proc { f1040.c9b }
    cell  '3', proc { f1040d.c15 > 0 && f1040d.c16 > 0 ? [f1040d.c15, f1040d.c16].min : 0 }
    cell  '4', proc { c2 + c3 }
    cell  '5', 0
    cell  '6', proc { c4 > c5 ? c4 - c5 : 0 }
    cell  '7', proc { c1 > c6 ? c1 - c6 : 0 }
    cell  '8', proc { tax_info.federal_bracket_limit(tax_year, filing_status, 0.15) }
    cell  '9', proc { [c1, c8].min }
    cell '10', proc { [c7, c9].min }
    cell '11', proc { c9 - c10 }
    cell '12', proc { [c1, c6].min }
    cell '13', proc { c11 }
    cell '14', proc { c12 - c13 }
    cell '15', proc { tax_info.federal_bracket_limit(tax_year, filing_status, 0.35) }
    cell '16', proc { [c1, c15].min }
    cell '17', proc { c7 + c11 }
    cell '18', proc { c16 > c17 ? c16 - c17 : 0 }
    cell '19', proc { [c14, c18].min }
    cell '20', proc { (c19 * 0.15).round(2) }
    cell '21', proc { c11 + c19 }
    cell '22', proc { c12 - c21 }
    cell '23', proc { (c22 * 0.2).round(2) }
    cell '24', proc { tax_info.calculate_tax(tax_year, filing_status, c7) }
    cell '25', proc { [c20, c23, c24].sum }
    cell '26', proc { tax_info.calculate_tax(tax_year, filing_status, c1) }
    cell '27', :tax, proc { [c25, c26].min }
  end
end
