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
      column :id, "character varying(15) DEFAULT next_id('u'::bpchar) not null"
      String :username, size: 255
      String :password, size: 255
      Timestamp :created_at, null: false
      Timestamp :updated_at, null: false
      primary_key [:id]
    end

    create_table :model_train_histories do
      column :id, "character varying(15) DEFAULT next_id('mt'::bpchar) not null"
      Timestamp :created_at, null: false
      Timestamp :ended_at, nulll: false
      String :problem_type, null: false
      column :result, :jsonb
      primary_key [:id]
      foreign_key :user_id, :users, :type=>'character varying(15)'
      index [:id, :user_id], :unique=>true
    end

    create_table :payments do
      column :id, "character varying(15) DEFAULT next_id('p'::bpchar) not null"
      Timestamp :payment_at, null: false
      String :payment_method, null: false
      column :payment_detail, "jsonb not null"
      primary_key [:id]
      foreign_key :user_id, :users, :type=>'character varying(15)'
      foreign_key :model_id, :model_train_histories, :type=>'character varying(15)'
      index [:model_id], :unique=>true
      index [:user_id,:model_id], :unique=>true
    end
  end

  down do
    drop_table :payments
    drop_table :model_train_histories
    drop_table :users
    drop_table :ids
    run 'DROP FUNCTION next_id(character)'
  end
end