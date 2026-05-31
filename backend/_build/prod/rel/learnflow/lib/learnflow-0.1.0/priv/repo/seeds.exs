alias Learnflow.{Accounts, Repo, Videos}
alias Learnflow.Accounts.User
alias Learnflow.Dashboard.{Playlist, PlaylistVideo}
alias Learnflow.Social.{Comment, Like}
alias Learnflow.Videos.{SubjectTag, Video, VideoChapter}
import Ecto.Query

now = DateTime.utc_now()

tags = [
  {"Mathematics", "mathematics", "#38bdf8"},
  {"Physics", "physics", "#f59e0b"},
  {"Chemistry", "chemistry", "#22c55e"},
  {"Biology", "biology", "#14b8a6"},
  {"Programming", "programming", "#22c55e"},
  {"History", "history", "#f97316"},
  {"Languages", "languages", "#14b8a6"},
  {"Economics", "economics", "#a855f7"},
  {"Design", "design", "#ec4899"},
  {"Business", "business", "#a855f7"},
  {"Philosophy", "philosophy", "#6366f1"}
]

Enum.each(tags, fn {name, slug, color} ->
  %SubjectTag{}
  |> SubjectTag.changeset(%{name: name, slug: slug, color: color})
  |> Repo.insert(on_conflict: [set: [name: name, color: color]], conflict_target: :slug)
end)

creator_specs = [
  {"arina_code", "arina@learnflow.dev", "Арина Волкова", "Объясняю программирование коротко, живо и без академического тумана."},
  {"math_azamat", "azamat@learnflow.dev", "Азамат Нуров", "Математика для тех, кто хочет наконец увидеть смысл за формулами."},
  {"design_mira", "mira@learnflow.dev", "Мира Саидова", "UX/UI, визуальные системы и продуктовый дизайн на реальных примерах."},
  {"physics_tim", "timur@learnflow.dev", "Тимур Исаков", "Физика через эксперименты, симуляции и понятные аналогии."},
  {"biz_aika", "aika@learnflow.dev", "Айка Бекова", "Бизнес, языки и навыки для роста: короткие уроки с практикой."}
]

creators =
  Enum.map(creator_specs, fn {username, email, display_name, bio} ->
    {:ok, user} =
      Accounts.register_user(%{
        "username" => username,
        "email" => email,
        "password" => "Creator123!",
        "display_name" => display_name,
        "is_creator" => true
      })
      |> case do
        {:ok, user} -> {:ok, user}
        {:error, _} -> {:ok, Repo.get_by!(User, email: email)}
      end

    user
    |> User.profile_changeset(%{display_name: display_name, bio: bio})
    |> Repo.update!()
  end)

learner_rows =
  for idx <- 1..220 do
    %{
      id: Ecto.UUID.generate(),
      username: "learner_#{idx}",
      email: "learner#{idx}@learnflow.dev",
      password_hash: "seeded-user",
      display_name: "Learner #{idx}",
      is_creator: false,
      is_verified: false,
      email_notifications: true,
      inserted_at: now,
      updated_at: now
    }
  end

Repo.insert_all(User, learner_rows, on_conflict: :nothing, conflict_target: :email)
learners = Repo.all(from u in User, where: like(u.email, "learner%@learnflow.dev"), order_by: [asc: u.email])

lessons = [
  {"Основы Python за 12 минут", "programming", "beginner", "Как переменные, условия и циклы складываются в первый настоящий скрипт.", 742},
  {"Линейная алгебра: векторы без боли", "mathematics", "beginner", "Векторы, базис и координаты на визуальных примерах.", 615},
  {"Дизайн-система в Figma", "design", "intermediate", "Цвета, типографика, компоненты и правила, которые держат продукт в форме.", 842},
  {"Законы Ньютона на пальцах", "physics", "beginner", "Почему сила, масса и ускорение объясняют почти все вокруг нас.", 506},
  {"Unit economics для стартапа", "business", "intermediate", "CAC, LTV, маржинальность и почему рост может быть опасным.", 694},
  {"Асинхронный JavaScript", "programming", "intermediate", "Promise, async/await и типичные ошибки при работе с API.", 780},
  {"Производные: геометрический смысл", "mathematics", "intermediate", "Скорость изменения, касательные и первая интуиция анализа.", 661},
  {"UX-аудит главного экрана", "design", "advanced", "Разбираем иерархию, сценарии пользователя и точки трения.", 925},
  {"Электричество: ток и напряжение", "physics", "beginner", "Простая модель цепи, которая помогает понимать схемы.", 571},
  {"Английский для презентаций", "languages", "beginner", "Фразы, структура и уверенная подача идей на английском.", 489},
  {"SQL JOIN на реальных таблицах", "programming", "intermediate", "INNER, LEFT, агрегаты и запросы для аналитики.", 718},
  {"Вероятность: байесовское мышление", "mathematics", "advanced", "Как обновлять уверенность, когда появляются новые данные.", 887},
  {"Цвет в интерфейсах", "design", "intermediate", "Контраст, акценты, состояния и палитры, которые не разваливаются.", 604},
  {"Квантовая физика: суперпозиция", "physics", "advanced", "Минимум мистики, максимум ясной интуиции.", 832},
  {"Маркетинговая воронка", "business", "beginner", "От первого касания до покупки: метрики и слабые места.", 532},
  {"Docker для новичков", "programming", "beginner", "Контейнеры, образы и compose на примере локальной базы.", 698},
  {"Матрицы в машинном обучении", "mathematics", "advanced", "Почему модели так любят матричное умножение.", 910},
  {"Прототип мобильного приложения", "design", "beginner", "От вайрфрейма до кликабельного flow за один урок.", 646},
  {"Термодинамика за 15 минут", "physics", "intermediate", "Температура, энергия и энтропия без лишней тяжести.", 756},
  {"Финансы фрилансера", "business", "beginner", "Ставка, резерв, налоги и планирование дохода.", 583}
]

mp4_urls = [
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
]

videos =
  lessons
  |> Enum.with_index()
  |> Enum.map(fn {{title, tag, difficulty, description, duration}, index} ->
    creator = Enum.at(creators, rem(index, length(creators)))

    {:ok, video} =
      case Repo.get_by(Video, title: title) do
        nil ->
          with {:ok, created} <-
                 Videos.create_video(creator, %{
                   "title" => title,
                   "description" => description,
                   "difficulty" => difficulty,
                   "language" => "ru",
                   "tags" => [tag]
                 }) do
            Videos.confirm_upload(created, %{
              "video_key" => Enum.at(mp4_urls, rem(index, length(mp4_urls))),
              "thumbnail_key" => "https://picsum.photos/seed/learnflow-#{index + 1}/900/1200",
              "duration_seconds" => duration
            })
          end

        existing ->
          {:ok, existing}
      end

    video
    |> Video.changeset(%{
      view_count: 2_400 + (index + 1) * 731,
      video_key: Enum.at(mp4_urls, rem(index, length(mp4_urls))),
      thumbnail_key: "https://picsum.photos/seed/learnflow-#{index + 1}/900/1200",
      duration_seconds: duration,
      status: "active",
      summary: "Короткий урок с практикой, контрольными вопросами и понятным итогом.",
      has_subtitles: true,
      subtitle_languages: ["ru"]
    })
    |> Repo.update!()
  end)

Enum.each(videos, fn video ->
  if Repo.aggregate(from(c in VideoChapter, where: c.video_id == ^video.id), :count) == 0 do
    chapters = [
      %{video_id: video.id, title: "Старт", start_seconds: 0, position: 0},
      %{video_id: video.id, title: "Практика", start_seconds: div(video.duration_seconds || 600, 3), position: 1},
      %{video_id: video.id, title: "Итоги", start_seconds: div((video.duration_seconds || 600) * 2, 3), position: 2}
    ]

    Enum.each(chapters, fn attrs ->
      %VideoChapter{} |> VideoChapter.changeset(attrs) |> Repo.insert!()
    end)
  end
end)

comment_bodies = [
  "Вот это наконец-то понятное объяснение. Сохранил урок.",
  "Можно продолжение с практическим заданием?",
  "Темп идеальный: быстро, но без ощущения, что тебя бросили посреди темы.",
  "Очень помогло перед проектом, спасибо!",
  "Нравится, что есть примеры из реальной работы.",
  "Пересмотрю еще раз вечером и сделаю конспект."
]

Enum.each(Enum.with_index(videos), fn {video, index} ->
  like_count = 10 + rem((index + 1) * 17, 191)
  comment_count = 3 + rem((index + 1) * 7, 28)

  like_rows =
    learners
    |> Enum.take(like_count)
    |> Enum.map(fn learner ->
      %{user_id: learner.id, video_id: video.id, inserted_at: now, updated_at: now}
    end)

  Repo.insert_all(Like, like_rows, on_conflict: :nothing)

  if Repo.aggregate(from(c in Comment, where: c.video_id == ^video.id), :count) < comment_count do
    comment_rows =
      learners
      |> Enum.drop(index)
      |> Enum.take(comment_count)
      |> Enum.with_index()
      |> Enum.map(fn {learner, comment_index} ->
        %{
          id: Ecto.UUID.generate(),
          user_id: learner.id,
          video_id: video.id,
          body: Enum.at(comment_bodies, rem(comment_index, length(comment_bodies))),
          is_deleted: false,
          inserted_at: DateTime.add(now, -comment_index * 1800, :second),
          updated_at: now
        }
      end)

    Repo.insert_all(Comment, comment_rows)
  end
end)

admin = Repo.get_by!(User, email: "arina@learnflow.dev")

for idx <- 1..5 do
  playlist =
    %Playlist{}
    |> Playlist.changeset(%{
      user_id: admin.id,
      title: "LearnFlow подборка #{idx}",
      description: "Seeded playlist #{idx}",
      is_public: true
    })
    |> Repo.insert!(on_conflict: :nothing)

  videos
  |> Enum.slice((idx - 1)..(idx + 1))
  |> Enum.with_index()
  |> Enum.each(fn {video, position} ->
    %PlaylistVideo{}
    |> PlaylistVideo.changeset(%{playlist_id: playlist.id, video_id: video.id, position: position})
    |> Repo.insert(on_conflict: :nothing)
  end)
end

IO.puts("Seeded LearnFlow with #{length(creators)} creators, #{length(videos)} videos, likes, comments, tags, and playlists.")
