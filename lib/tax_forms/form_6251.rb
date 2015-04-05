TaxFormBuilder.constructify do
  form '6251' do
    # Alternative Minimum Taxable Income
    cell  '1', proc { f1040a.itemized_deductions == f1040.c40 ? f1040.c41 : f1040.c38 }
    cell  '2', 0
    cell  '3', proc { f1040a.itemized_deductions == f1040.c40 ? f1040a.c9 : 0 }
    cell  '4', proc { f1040a.itemized_deductions == f1040.c40 ? fhome_mortgage_interest_adjustment_worksheet.c6 : 0}
    cell  '5', proc { f1040a.itemized_deductions == f1040.c40 ? f1040a.c27 : 0 }
    cell  '6', proc {
      if f1040a.itemized_deductions == f1040.c40 && f1040.c38 > tax_info.personal_exemption_limit(tax_year, filing_status)
        -fitemized_deductions_worksheet.c9
      else
        0
      end
    }
    cell  '7', proc { [f1040.c10, f1040.c21].max }
    cell  '8', 0
    cell  '9', 0
    cell '10', 0
    cell '11', 0
    cell '12', 0
    cell '13', 0
    cell '14', 0
    cell '15', 0
    cell '16', 0
    cell '17', 0
    cell '18', 0
    cell '19', 0
    cell '20', 0
    cell '21', 0
    cell '22', 0
    cell '23', 0
    cell '24', 0
    cell '25', 0
    cell '26', 0
    cell '27', 0
    cell '28', :alternative_minimum_taxable_income, proc {
      [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16,
       c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27].sum
    }
    # Alternative Minimum Tax
    cell '29', proc { fexemption_worksheet.c6 }
    cell '30', proc { c28 > c29 ? c28 - c29 : 0 }
    cell '31', proc { famt_tax_computation_worksheet.c64 }
    cell '32', 0    # TODO Support foreign tax credits
    cell '33', proc { c31 - c32 }
    cell '34', proc { f1040.c44 + c1040.c46 - c1040.c48 }
    cell '35', :amt, proc { c33 > c34 ? c33 - c34 : 0 }
  end

  #
  # == WORKSHEETS ==
  #

  form :home_mortgage_interest_adjustment_worksheet do
    cell '1', proc { [f1040a.c10, f1040a.c11, f1040a.c12, f1040a.c13].sum }
    cell '2', proc { c1 }
    cell '3', 0
    cell '4', 0
    cell '5', proc { [c2, c3, c4].sum }
    cell '6', proc { c1 - c5 }
  end

  form :exemption_worksheet do
    cell '1', proc { tax_info.amt_exemption(tax_year, filing_status) }
    cell '2', proc { f6251.alternaive_minimum_taxable_income }
    cell '3', proc { tax_info.amt_exemption_limit(tax_year, filing_status) }
    cell '4', proc { c2 > c3 ? c2 - c3 : 0 }
    cell '5', proc { (c4 * 0.25).round(2) }
    cell '6', proc { c1 > c5 ? c1 - c5 : 0 }
  end

  form :amt_tax_computation_worksheet do
    cell '36', proc { f6251.c30 }
    cell '37', proc { f1040d.c13 }
    cell '38', proc { f1040d.c19 }
    cell '39', proc { c37 }
    cell '40', proc { [c36, c39].min }
    cell '41', proc { c36 - c40 }
    cell '42', proc { (c41 <= tax_info.amt_bracket_limit(tax_year) ? c41 * 0.26 : c41 * 0.28 - tax_info.amt_tax_subtraction(tax_year)).round(2) }
    cell '43', proc { tax_info.federal_bracket_limit(tax_year, filing_status, 0.15) }
    cell '44', proc { fqualified_dividends_and_capital_gain_tax_worksheet.c7 }
    cell '45', proc { c43 > c44 ? c43 - c44 : 0 }
    cell '46', proc { [c36, c37].min }
    cell '47', proc { [c45, c46].min }
    cell '48', proc { c46 - c47 }
    cell '49', proc { tax_info.federal_bracket_limit(tax_year, filing_status, 0.35) }
    cell '50', proc { c45 }
    cell '51', proc { fqualified_dividends_and_capital_gain_tax_worksheet.c7 }
    cell '52', proc { c50 + c51 }
    cell '53', proc { c49 > c52 ? c49 - c52 : 0 }
    cell '54', proc { [c48, c53].min }
    cell '55', proc { (c54 * 0.15).round(2) }
    cell '56', proc { c47 + c54 }
    cell '57', proc { c56 == c36 ? 0 : c46 - c56 }
    cell '58', proc { c56 == c36 ? 0 : (c57 * 0.2).round(2) }
    cell '59', proc { c56 == c36 || c38 == 0 ? 0 : [c41, c56, c57].sum }
    cell '60', proc { c56 == c36 || c38 == 0 ? 0 : c36 - c59 }
    cell '61', proc { c56 == c36 || c38 == 0 ? 0 : (c60 * 0.25).round(2) }
    cell '62', proc { [c42, c55, c58, c61].sum }
    cell '63', proc { (c36 <= tax_info.amt_bracket_limit(tax_year) ? c36 * 0.26 : c36 * 0.28 - tax_info.amt_tax_subtraction(tax_year)).round(2) }
    cell '64', proc { [c62, c63].min }
  end

end
