defmodule Learnflow.Repo.Migrations.EnableRowLevelSecurity do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE users ENABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE watch_progress ENABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE likes ENABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE saves ENABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE comments ENABLE ROW LEVEL SECURITY")

    execute("""
    CREATE POLICY users_own_rows ON users
    USING (current_setting('app.role', true) = 'service' OR id::text = current_setting('app.current_user_id', true))
    WITH CHECK (current_setting('app.role', true) = 'service' OR id::text = current_setting('app.current_user_id', true))
    """)

    execute("""
    CREATE POLICY watch_progress_own_rows ON watch_progress
    USING (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    WITH CHECK (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    """)

    execute("""
    CREATE POLICY likes_own_rows ON likes
    USING (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    WITH CHECK (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    """)

    execute("""
    CREATE POLICY saves_own_rows ON saves
    USING (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    WITH CHECK (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    """)

    execute("""
    CREATE POLICY comments_own_rows ON comments
    USING (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    WITH CHECK (current_setting('app.role', true) = 'service' OR user_id::text = current_setting('app.current_user_id', true))
    """)
  end

  def down do
    execute("DROP POLICY IF EXISTS comments_own_rows ON comments")
    execute("DROP POLICY IF EXISTS saves_own_rows ON saves")
    execute("DROP POLICY IF EXISTS likes_own_rows ON likes")
    execute("DROP POLICY IF EXISTS watch_progress_own_rows ON watch_progress")
    execute("DROP POLICY IF EXISTS users_own_rows ON users")
    execute("ALTER TABLE comments DISABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE saves DISABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE likes DISABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE watch_progress DISABLE ROW LEVEL SECURITY")
    execute("ALTER TABLE users DISABLE ROW LEVEL SECURITY")
  end
end
