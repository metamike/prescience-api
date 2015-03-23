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
    cell '10',  proc { state_income_tax_refund }
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
      itemized = f1040_sa.itemized_deductions
      [itemized, standard_deduction_worksheet.standard_deduction].max
    }
    cell '41', proc { c38 - c40 }
    cell '42', :exemptions, proc { exemptions_worksheet.deduction }
    cell '43', :taxable_income, proc { c42 <= c41 ? c41 - c42 : 0 }
    cell '44', :tax, proc { qualified_dividends_and_capital_gain_tax_worksheet.tax }
  end

  #
  # == WORKSHEETS ==
  #

  # Standard Deducsion
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
    cell '1', proc { f1040.taxable_income }
    cell '2', proc { f1040.c9b }
    # TODO Finish this sheet
  end
end
