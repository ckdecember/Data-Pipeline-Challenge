CREATE TABLE IF NOT EXISTS master_loan
(
	  id                                         text,
	  member_id                                  text,
	  loan_amnt                                  text,
	  funded_amnt                                text,
	  funded_amnt_inv                            text,
	  term                                       text,
	  int_rate                                   text,
	  installment                                text,
	  grade                                      text,
	  sub_grade                                  text,
	  emp_title                                  text,
	  emp_length                                 text,
	  home_ownership                             text,
	  annual_inc                                 text,
	  verification_status                        text,
	  issue_d                                    text,
	  loan_status                                text,
	  pymnt_plan                                 text,
	  url                                        text,
	  "desc"                                     text,
	  purpose                                    text,
	  title                                      text,
	  zip_code                                   text,
	  addr_state                                 text,
	  dti                                        text,
	  delinq_2yrs                                text,
	  earliest_cr_line                           text,
	  inq_last_6mths                             text,
	  mths_since_last_delinq                     text,
	  mths_since_last_record                     text,
	  open_acc                                   text,
	  pub_rec                                    text,
	  revol_bal                                  text,
	  revol_util                                 text,
	  total_acc                                  text,
	  initial_list_status                        text,
	  out_prncp                                  text,
	  out_prncp_inv                              text,
	  total_pymnt                                text,
	  total_pymnt_inv                            text,
	  total_rec_prncp                            text,
	  total_rec_int                              text,
	  total_rec_late_fee                         text,
	  recoveries                                 text,
	  collection_recovery_fee                    text,
	  last_pymnt_d                               text,
	  last_pymnt_amnt                            text,
	  next_pymnt_d                               text,
	  last_credit_pull_d                         text,
	  collections_12_mths_ex_med                 text,
	  mths_since_last_major_derog                text,
	  policy_code                                text,
	  application_type                           text,
	  annual_inc_joint                           text,
	  dti_joint                                  text,
	  verification_status_joint                  text,
	  acc_now_delinq                             text,
	  tot_coll_amt                               text,
	  tot_cur_bal                                text,
	  open_acc_6m                                text,
	  open_act_il                                text,
	  open_il_12m                                text,
	  open_il_24m                                text,
	  mths_since_rcnt_il                         text,
	  total_bal_il                               text,
	  il_util                                    text,
	  open_rv_12m                                text,
	  open_rv_24m                                text,
	  max_bal_bc                                 text,
	  all_util                                   text,
	  total_rev_hi_lim                           text,
	  inq_fi                                     text,
	  total_cu_tl                                text,
	  inq_last_12m                               text,
	  acc_open_past_24mths                       text,
	  avg_cur_bal                                text,
	  bc_open_to_buy                             text,
	  bc_util                                    text,
	  chargeoff_within_12_mths                   text,
	  delinq_amnt                                text,
	  mo_sin_old_il_acct                         text,
	  mo_sin_old_rev_tl_op                       text,
	  mo_sin_rcnt_rev_tl_op                      text,
	  mo_sin_rcnt_tl                             text,
	  mort_acc                                   text,
	  mths_since_recent_bc                       text,
	  mths_since_recent_bc_dlq                   text,
	  mths_since_recent_inq                      text,
	  mths_since_recent_revol_delinq             text,
	  num_accts_ever_120_pd                      text,
	  num_actv_bc_tl                             text,
	  num_actv_rev_tl                            text,
	  num_bc_sats                                text,
	  num_bc_tl                                  text,
	  num_il_tl                                  text,
	  num_op_rev_tl                              text,
	  num_rev_accts                              text,
	  num_rev_tl_bal_gt_0                        text,
	  num_sats                                   text,
	  num_tl_120dpd_2m                           text,
	  num_tl_30dpd                               text,
	  num_tl_90g_dpd_24m                         text,
	  num_tl_op_past_12m                         text,
	  pct_tl_nvr_dlq                             text,
	  percent_bc_gt_75                           text,
	  pub_rec_bankruptcies                       text,
	  tax_liens                                  text,
	  tot_hi_cred_lim                            text,
	  total_bal_ex_mort                          text,
	  total_bc_limit                             text,
	  total_il_high_credit_limit                 text,
	  revol_bal_joint                            text,
	  sec_app_earliest_cr_line                   text,
	  sec_app_inq_last_6mths                     text,
	  sec_app_mort_acc                           text,
	  sec_app_open_acc                           text,
	  sec_app_revol_util                         text,
	  sec_app_open_act_il                        text,
	  sec_app_num_rev_accts                      text,
	  sec_app_chargeoff_within_12_mths           text,
	  sec_app_collections_12_mths_ex_med         text,
	  sec_app_mths_since_last_major_derog        text,
	  hardship_flag                              text,
	  hardship_type                              text,
	  hardship_reason                            text,
	  hardship_status                            text,
	  deferral_term                              text,
	  hardship_amount                            text,
	  hardship_start_date                        text,
	  hardship_end_date                          text,
	  payment_plan_start_date                    text,
	  hardship_length                            text,
	  hardship_dpd                               text,
	  hardship_loan_status                       text,
	  orig_projected_additional_accrued_interest text,
	  hardship_payoff_balance_amount             text,
	  hardship_last_payment_amount               text,
	  disbursement_method                        text,
	  debt_settlement_flag                       text,
	  debt_settlement_flag_date                  text,
	  settlement_status                          text,
	  settlement_date                            text,
	  settlement_amount                          text,
	  settlement_percentage                      text,
	  settlement_term                            text
);

