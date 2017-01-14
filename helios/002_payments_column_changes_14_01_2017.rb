Sequel.migration do
  up do
    alter_table(:payments) do
      set_column_allow_null(:payment_at)
      set_column_allow_null(:payment_method)
      set_column_allow_null(:payment_detail)
    end
  end

  down do
  end
end
