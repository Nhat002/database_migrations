Sequel.migration do

  up do
    run <<-EOF
CREATE FUNCTION next_id(character) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
      DECLARE id varchar(15);
      begin
        update ids
        set current = current + 1
        where resource = $1
        returning cast(current as varchar) || $1 into id;
        return id;
      end
      $_$;
    EOF

    create_table :ids do
      String :resource, fixed: true, size: 2, null: false
      Fixnum :current, default: 0, null: false
      primary_key [:resource]
    end

    create_table :users do
      column :id, String, size:15,null: false
      String :username, size: 255
      String :password, size: 255
      Timestamp :created_at, null: false
      Timestamp :updated_at
      primary_key [:id]
    end

    run <<-EOF
ALTER TABLE users ALTER COLUMN id SET DEFAULT next_id('u'::bpchar);
    EOF

    create_table :records do
      column :id, String, size:15,null: false
      String :title, size: 255
      String :description
      Timestamp :created_at, null: false
      Timestamp :ended_at
      String :type, null: false
      String :dataset_link
      column :run_params, :jsonb
      String :status
      column :result, :jsonb
      primary_key [:id]
      foreign_key :user_id, :users, :type=>'character varying(15)'
      index [:id, :user_id], :unique=>true
    end

    run <<-EOF
ALTER TABLE records ALTER COLUMN id SET DEFAULT next_id('r'::bpchar);
    EOF

    create_table :payments do
      column :id, String, size:15,null: false
      Timestamp :payment_at, null: false
      String :payment_method, null: false
      String :amount
      String :payment_status, null: false
      column :payment_detail, "jsonb not null"
      primary_key [:id]
      foreign_key :user_id, :users, :type=>'character varying(15)'
      foreign_key :record_id, :records, :type=>'character varying(15)'
      index [:record_id], :unique=>true
      index [:user_id], :unique=>true
    end
    run <<-EOF
ALTER TABLE payments ALTER COLUMN id SET DEFAULT next_id('p'::bpchar);
    EOF
    alter_table(:records) do
      add_foreign_key :payment_id, :payments, :type=>'character varying(15)'
      add_index [:id, :payment_id], :unique=>true
    end
  end


  down do
    drop_table :payments
    drop_table :records
    drop_table :users
    drop_table :ids
    run 'DROP FUNCTION next_id(character)'
  end
end