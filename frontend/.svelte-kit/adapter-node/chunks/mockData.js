//#region src/lib/mockData.js
var authors = [
	{
		id: "a1",
		username: "arina_code",
		display_name: "Арина Волкова",
		bio: "Объясняю программирование коротко, живо и без академического тумана.",
		avatar_url: "https://i.pravatar.cc/160?img=47",
		followers_count: 42800,
		following_count: 128,
		videos_count: 38,
		tags: [
			"Python",
			"Алгоритмы",
			"Backend"
		]
	},
	{
		id: "a2",
		username: "math_azamat",
		display_name: "Азамат Нуров",
		bio: "Математика для тех, кто хочет наконец увидеть смысл за формулами.",
		avatar_url: "https://i.pravatar.cc/160?img=12",
		followers_count: 31500,
		following_count: 94,
		videos_count: 25,
		tags: [
			"Алгебра",
			"Анализ",
			"Статистика"
		]
	},
	{
		id: "a3",
		username: "design_mira",
		display_name: "Мира Саидова",
		bio: "UX/UI, визуальные системы и продуктовый дизайн на реальных примерах.",
		avatar_url: "https://i.pravatar.cc/160?img=32",
		followers_count: 51200,
		following_count: 210,
		videos_count: 44,
		tags: [
			"Дизайн",
			"Figma",
			"UX"
		]
	},
	{
		id: "a4",
		username: "physics_tim",
		display_name: "Тимур Исаков",
		bio: "Физика через эксперименты, симуляции и понятные аналогии.",
		avatar_url: "https://i.pravatar.cc/160?img=59",
		followers_count: 18900,
		following_count: 76,
		videos_count: 19,
		tags: [
			"Физика",
			"Механика",
			"Космос"
		]
	},
	{
		id: "a5",
		username: "biz_aika",
		display_name: "Айка Бекова",
		bio: "Бизнес, языки и навыки для роста: короткие уроки с практикой.",
		avatar_url: "https://i.pravatar.cc/160?img=5",
		followers_count: 27600,
		following_count: 182,
		videos_count: 31,
		tags: [
			"Бизнес",
			"Английский",
			"Маркетинг"
		]
	}
];
var lessons = [
	[
		"Основы Python за 12 минут",
		"programming",
		"beginner",
		"Как переменные, условия и циклы складываются в первый настоящий скрипт.",
		742,
		18
	],
	[
		"Линейная алгебра: векторы без боли",
		"mathematics",
		"beginner",
		"Векторы, базис и координаты на визуальных примерах.",
		615,
		14
	],
	[
		"Дизайн-система в Figma",
		"design",
		"intermediate",
		"Цвета, типографика, компоненты и правила, которые держат продукт в форме.",
		842,
		24
	],
	[
		"Законы Ньютона на пальцах",
		"physics",
		"beginner",
		"Почему сила, масса и ускорение объясняют почти все вокруг нас.",
		506,
		11
	],
	[
		"Unit economics для стартапа",
		"business",
		"intermediate",
		"CAC, LTV, маржинальность и почему рост может быть опасным.",
		694,
		16
	],
	[
		"Асинхронный JavaScript",
		"programming",
		"intermediate",
		"Promise, async/await и типичные ошибки при работе с API.",
		780,
		22
	],
	[
		"Производные: геометрический смысл",
		"mathematics",
		"intermediate",
		"Скорость изменения, касательные и первая интуиция анализа.",
		661,
		15
	],
	[
		"UX-аудит главного экрана",
		"design",
		"advanced",
		"Разбираем иерархию, сценарии пользователя и точки трения.",
		925,
		28
	],
	[
		"Электричество: ток и напряжение",
		"physics",
		"beginner",
		"Простая модель цепи, которая помогает понимать схемы.",
		571,
		13
	],
	[
		"Английский для презентаций",
		"languages",
		"beginner",
		"Фразы, структура и уверенная подача идей на английском.",
		489,
		9
	],
	[
		"SQL JOIN на реальных таблицах",
		"programming",
		"intermediate",
		"INNER, LEFT, агрегаты и запросы для аналитики.",
		718,
		21
	],
	[
		"Вероятность: байесовское мышление",
		"mathematics",
		"advanced",
		"Как обновлять уверенность, когда появляются новые данные.",
		887,
		25
	],
	[
		"Цвет в интерфейсах",
		"design",
		"intermediate",
		"Контраст, акценты, состояния и палитры, которые не разваливаются.",
		604,
		17
	],
	[
		"Квантовая физика: суперпозиция",
		"physics",
		"advanced",
		"Минимум мистики, максимум ясной интуиции.",
		832,
		19
	],
	[
		"Маркетинговая воронка",
		"business",
		"beginner",
		"От первого касания до покупки: метрики и слабые места.",
		532,
		12
	],
	[
		"Docker для новичков",
		"programming",
		"beginner",
		"Контейнеры, образы и compose на примере локальной базы.",
		698,
		20
	],
	[
		"Матрицы в машинном обучении",
		"mathematics",
		"advanced",
		"Почему модели так любят матричное умножение.",
		910,
		27
	],
	[
		"Прототип мобильного приложения",
		"design",
		"beginner",
		"От вайрфрейма до кликабельного flow за один урок.",
		646,
		18
	],
	[
		"Термодинамика за 15 минут",
		"physics",
		"intermediate",
		"Температура, энергия и энтропия без лишней тяжести.",
		756,
		16
	],
	[
		"Финансы фрилансера",
		"business",
		"beginner",
		"Ставка, резерв, налоги и планирование дохода.",
		583,
		10
	]
];
var tagColors = {
	programming: "#22c55e",
	mathematics: "#38bdf8",
	design: "#ec4899",
	physics: "#f59e0b",
	business: "#a855f7",
	languages: "#14b8a6"
};
var mp4Urls = [
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
];
var videos = lessons.map((lesson, index) => {
	const author = authors[index % authors.length];
	const [title, tag, difficulty, description, duration, comments] = lesson;
	const id = index + 1;
	return {
		id: `v${id}`,
		slug: title.toLowerCase().replace(/[^a-zа-я0-9]+/gi, "-").replace(/^-|-$/g, ""),
		title,
		description,
		difficulty,
		language: "ru",
		duration_seconds: duration,
		thumbnail_url: `https://picsum.photos/seed/learnflow-${id}/900/1200`,
		wide_thumbnail_url: `https://picsum.photos/seed/learnflow-wide-${id}/1280/720`,
		video_key: mp4Urls[index % mp4Urls.length],
		view_url: "",
		view_count: 2400 + id * 731,
		like_count: 10 + id * 17 % 191,
		comment_count: comments,
		progress: 18 + id * 7 % 78,
		creator: author,
		tags: [{
			name: tagLabel(tag),
			slug: tag,
			color: tagColors[tag] || "#6366f1"
		}],
		chapters: [
			{
				title: "Старт",
				start_seconds: 0,
				position: 0
			},
			{
				title: "Практика",
				start_seconds: Math.round(duration * .34),
				position: 1
			},
			{
				title: "Итоги",
				start_seconds: Math.round(duration * .72),
				position: 2
			}
		]
	};
});
var comments = [
	{
		id: "c1",
		user: authors[1],
		body: "Вот это наконец-то понятное объяснение. Сохранил урок.",
		ago: "2ч назад",
		likes: 14,
		replies: 3
	},
	{
		id: "c2",
		user: authors[2],
		body: "Можно продолжение с практическим заданием?",
		ago: "4ч назад",
		likes: 8,
		replies: 1
	},
	{
		id: "c3",
		user: authors[3],
		body: "Темп идеальный: быстро, но без ощущения, что тебя бросили посреди темы.",
		ago: "вчера",
		likes: 21,
		replies: 0
	}
];
var notifications = [
	["Сегодня", [
		{
			id: "n1",
			unread: true,
			avatar: authors[0].avatar_url,
			text: "Арина Волкова лайкнула ваш комментарий",
			time: "5 мин",
			thumbnail: videos[0].thumbnail_url
		},
		{
			id: "n2",
			unread: true,
			avatar: authors[2].avatar_url,
			text: "Мира Саидова подписалась на вас",
			time: "28 мин"
		},
		{
			id: "n3",
			unread: false,
			avatar: authors[4].avatar_url,
			text: "Новый урок: Unit economics для стартапа",
			time: "2ч",
			thumbnail: videos[4].thumbnail_url
		}
	]],
	["На этой неделе", [{
		id: "n4",
		unread: false,
		avatar: authors[1].avatar_url,
		text: "Азамат ответил на ваш вопрос по алгебре",
		time: "2д",
		thumbnail: videos[6].thumbnail_url
	}, {
		id: "n5",
		unread: false,
		avatar: authors[3].avatar_url,
		text: "Ваш прогресс в курсе физики достиг 65%",
		time: "4д"
	}]],
	["Ранее", [{
		id: "n6",
		unread: false,
		avatar: authors[2].avatar_url,
		text: "Подборка дизайна недели уже доступна",
		time: "12д",
		thumbnail: videos[12].thumbnail_url
	}]]
];
function formatDuration(seconds = 0) {
	const minutes = Math.floor(seconds / 60);
	const rest = seconds % 60;
	return `${minutes}:${String(rest).padStart(2, "0")}`;
}
function findVideo(slug) {
	return videos.find((video) => video.slug === slug) || videos[0];
}
function findAuthor(username) {
	return authors.find((author) => author.username === username) || authors[0];
}
function tagLabel(slug) {
	return {
		programming: "Программирование",
		mathematics: "Математика",
		design: "Дизайн",
		physics: "Физика",
		business: "Бизнес",
		languages: "Языки"
	}[slug] || slug;
}
//#endregion
export { formatDuration as a, findVideo as i, comments as n, notifications as o, findAuthor as r, videos as s, authors as t };
