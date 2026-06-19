class CreateProductopsSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "developer"
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :role

    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :key, null: false
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :projects, %i[organization_id key], unique: true
    add_index :projects, :deleted_at

    create_table :memberships do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.timestamps
    end
    add_index :memberships, %i[user_id organization_id project_id], unique: true, name: "idx_memberships_unique_scope"

    create_table :requirements do |t|
      t.references :project, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :assigned_owner, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.text :business_value
      t.string :priority, null: false, default: "medium"
      t.string :status, null: false, default: "draft"
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :requirements, :status
    add_index :requirements, :priority
    add_index :requirements, :deleted_at

    create_table :requirement_gaps do |t|
      t.references :requirement, null: false, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.string :severity, null: false, default: "medium"
      t.string :status, null: false, default: "open"
      t.text :resolution_note
      t.datetime :resolved_at
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :requirement_gaps, :status

    create_table :clarification_questions do |t|
      t.references :requirement, null: false, foreign_key: true
      t.references :asked_by, null: false, foreign_key: { to_table: :users }
      t.references :answered_by, foreign_key: { to_table: :users }
      t.text :question, null: false
      t.text :answer
      t.string :status, null: false, default: "open"
      t.timestamps
    end
    add_index :clarification_questions, :status

    create_table :decision_notes do |t|
      t.references :requirement, null: false, foreign_key: true
      t.references :decided_by, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :decision, null: false
      t.text :rationale
      t.timestamps
    end

    create_table :meeting_notes do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :attendees
      t.text :notes
      t.text :action_items
      t.date :meeting_date
      t.timestamps
    end

    create_table :sprints do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :goal
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: "planning"
      t.timestamps
    end
    add_index :sprints, :status

    create_table :wbs_items do |t|
      t.references :requirement, null: false, foreign_key: true
      t.references :sprint, foreign_key: true
      t.references :owner, foreign_key: { to_table: :users }
      t.string :task_key
      t.string :title, null: false
      t.text :description
      t.string :category, null: false, default: "backend"
      t.decimal :estimated_hours, precision: 8, scale: 2, null: false
      t.decimal :actual_hours, precision: 8, scale: 2, null: false, default: 0
      t.string :complexity, null: false, default: "medium"
      t.string :risk_level, null: false, default: "medium"
      t.string :status, null: false, default: "backlog"
      t.date :due_date
      t.text :blocked_reason
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :wbs_items, :status
    add_index :wbs_items, :risk_level
    add_index :wbs_items, :task_key
    add_index :wbs_items, :deleted_at

    create_table :task_dependencies do |t|
      t.references :predecessor_task, null: false, foreign_key: { to_table: :wbs_items }
      t.references :successor_task, null: false, foreign_key: { to_table: :wbs_items }
      t.string :dependency_type, null: false, default: "blocks"
      t.timestamps
    end
    add_index :task_dependencies, %i[predecessor_task_id successor_task_id], unique: true, name: "idx_task_dependencies_unique_pair"

    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :commentable, polymorphic: true, null: false
      t.text :body, null: false
      t.timestamps
    end

    create_table :releases do |t|
      t.references :project, null: false, foreign_key: true
      t.references :sprint, foreign_key: true
      t.references :release_owner, null: false, foreign_key: { to_table: :users }
      t.string :version_number, null: false
      t.string :title, null: false
      t.date :target_date
      t.string :environment, null: false, default: "staging"
      t.string :status, null: false, default: "draft"
      t.text :production_override_reason
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :releases, %i[project_id version_number], unique: true
    add_index :releases, :status

    create_table :release_checklists do |t|
      t.references :release, null: false, foreign_key: true
      t.boolean :code_review_completed, null: false, default: false
      t.boolean :unit_tests_passed, null: false, default: false
      t.boolean :qa_verified, null: false, default: false
      t.boolean :db_migration_reviewed, null: false, default: false
      t.boolean :rollback_plan_added, null: false, default: false
      t.boolean :staging_deployment_done, null: false, default: false
      t.boolean :production_approval_received, null: false, default: false
      t.timestamps
    end

    create_table :deployments do |t|
      t.references :release, null: false, foreign_key: true
      t.references :deployed_by, foreign_key: { to_table: :users }
      t.string :environment, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :deployed_at
      t.text :rollback_reason
      t.text :logs
      t.timestamps
    end
    add_index :deployments, :status

    create_table :risk_reports do |t|
      t.references :project, null: false, foreign_key: true
      t.references :sprint, foreign_key: true
      t.references :release, foreign_key: true
      t.integer :risk_score, null: false
      t.string :risk_level, null: false
      t.jsonb :reasons, null: false, default: []
      t.jsonb :suggested_actions, null: false, default: []
      t.jsonb :payload, null: false, default: {}
      t.timestamps
    end
    add_index :risk_reports, :risk_level

    create_table :svn_commits do |t|
      t.references :project, null: false, foreign_key: true
      t.references :wbs_item, foreign_key: true
      t.string :revision, null: false
      t.string :author, null: false
      t.datetime :committed_at, null: false
      t.text :message
      t.jsonb :changed_paths, null: false, default: []
      t.string :task_key
      t.datetime :imported_at, null: false
      t.timestamps
    end
    add_index :svn_commits, %i[project_id revision], unique: true
    add_index :svn_commits, :task_key

    create_table :build_runs do |t|
      t.references :project, null: false, foreign_key: true
      t.string :build_tool, null: false, default: "ant"
      t.string :status, null: false
      t.integer :duration_seconds, null: false, default: 0
      t.integer :failed_test_count, null: false, default: 0
      t.text :log_output
      t.datetime :executed_at, null: false
      t.timestamps
    end
    add_index :build_runs, :status

    create_table :activity_logs do |t|
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true
      t.string :entity_type, null: false
      t.bigint :entity_id
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :activity_logs, :action
    add_index :activity_logs, %i[entity_type entity_id]
  end
end
