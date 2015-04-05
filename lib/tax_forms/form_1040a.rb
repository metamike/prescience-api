TaxFormBuilder.constructify do
  form '1040a' do
    # Medical and Dental Expenses
    cell '1', proc { medical_expenses }
    cell '2', proc { f1040.adjusted_gross_income }
    cell '3', proc { (c2 * 0.1).round(2) }
    cell '4', proc { c3 > c1 ? 0 : c1 - c3 }
    # Taxes You Paid
    cell '5', proc { state_income_tax_withheld }
    cell '6', proc { real_estate_taxes }
    cell '7', 0
    cell '8', 0
    cell '9', proc { [c5, c6, c7, c8].sum }
    # Interest You Paid
    cell '10', proc { fmortgage_interest_worksheet.deductible_home_mortgage_interest }
    cell '11', 0
    cell '12', 0
    cell '13', 0
    cell '14', 0
    cell '15', proc { [c10, c11, c12, c13, c14].sum }
    # Gifts to Charity
    cell '16', proc { charity }
    cell '17', 0
    cell '18', 0
    cell '19', proc { [c16, c17, c18].sum }
    # Casualty and Theft Losses
    cell '20', 0
    # Job Expenses and Certain Miscellaneous Deductions
    cell '21', 0
    cell '22', 0
    cell '23', 0
    cell '24', proc { [c21, c22, c23].sum }
    cell '25', proc { f1040.adjusted_gross_income }
    cell '26', proc { (c25 * 0.02).round(2) }
    cell '27', proc { c26 > c24 ? 0 : c24 - c26 }
    # Other Miscellaneous Deductions
    cell '28' 0
    # Total Itemized Deductions
    cell '29'
  end

  # Mortgage Interest Worksheet
  form :mortgage_interest_worksheet do
    # Qualified Loan Limit
    cell '1', 0
    cell '2', proc { ((mortgage_starting_balance + mortgage_ending_balance) / 2.0).round(2) }
    cell '3', BigDecimal.new('1000000')
    cell '4', proc { [c1, c3].max }
    cell '5', proc { c1 + c2 }
    cell '6', proc { [c4, c5].min }
    cell '7', 0
    cell '8', :qualified_loan_limit, proc { c6 + c7 }

    # Deductible Home Mortgage Interest
    cell '9', proc { c2 }
    cell '10', proc { mortgage_interest }
    cell '11', proc { [1, (c8 / c9)].min.round(3) }
    cell '12', :deductible_home_mortgage_interest, proc { (c10 * c11).round(2) }
    cell '13', proc { c10 - c12 }
  end

  form :itemized_deductions_worksheet do
    cell '1', proc { [f1040a.c4, f1040a.c9, f1040a.c15, f1040a.c19, f1040a.c20,
                      f1040a.c27, f1040a.c28].sum }
    cell '2', proc { [f1040a.c4, f1040a.c14, f1040a.c20, f1040a.c28].sum }
    cell '3', proc { c2 < c1 ? :stop : c1 - c2 }
    cell '4', proc { (c3 * 0.8).round(2) }
    cell '5', proc { f1040.adjusted_gross_income }
    cell '6', proc { tax_info.personal_exemption_income_limit(tax_year, filing_status) }
    cell '7', proc { c6 < c5 ? :stop : c5 - c6 }
    cell '8', proc { (c7 * 0.03).round(2) }
    cell '9', proc { [c4, c8].min }
    cell '10', :total_itemized_deductions, proc { c1 - c9 }
  end
end
