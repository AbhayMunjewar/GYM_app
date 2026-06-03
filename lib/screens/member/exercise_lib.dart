<!DOCTYPE html>

<html class="dark" lang="en"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Velocity AI | Exercise Library</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700;800&amp;family=JetBrains+Mono:wght@500&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .glass-card {
            background: rgba(28, 28, 30, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .primary-glow:hover {
            box-shadow: 0 0 15px rgba(202, 243, 0, 0.3);
        }
        ::-webkit-scrollbar {
            width: 6px;
        }
        ::-webkit-scrollbar-track {
            background: #0a0a0a;
        }
        ::-webkit-scrollbar-thumb {
            background: #353534;
            border-radius: 10px;
        }
    </style>
<!-- Tailwind Config Verbatim -->
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "on-secondary-fixed": "#001a41",
                    "surface-tint": "#b0d500",
                    "secondary-container": "#4b8eff",
                    "surface-container-high": "#2a2a2a",
                    "on-error-container": "#ffdad6",
                    "tertiary-fixed-dim": "#c6c6c7",
                    "surface-container": "#201f1f",
                    "on-tertiary-fixed": "#1a1c1c",
                    "on-secondary": "#002e69",
                    "error": "#ffb4ab",
                    "surface-container-highest": "#353534",
                    "on-primary-container": "#596c00",
                    "primary-fixed-dim": "#b0d500",
                    "surface-container-low": "#1c1b1b",
                    "on-tertiary": "#2f3131",
                    "background": "#131313",
                    "on-primary-fixed": "#171e00",
                    "inverse-primary": "#536600",
                    "on-secondary-fixed-variant": "#004493",
                    "error-container": "#93000a",
                    "inverse-surface": "#e5e2e1",
                    "secondary-fixed-dim": "#adc6ff",
                    "on-primary-fixed-variant": "#3e4c00",
                    "surface-container-lowest": "#0e0e0e",
                    "on-tertiary-fixed-variant": "#454747",
                    "on-surface": "#e5e2e1",
                    "inverse-on-surface": "#313030",
                    "surface-dim": "#131313",
                    "surface-variant": "#353534",
                    "on-primary": "#2a3400",
                    "on-error": "#690005",
                    "primary-fixed": "#caf300",
                    "secondary": "#adc6ff",
                    "on-background": "#e5e2e1",
                    "on-surface-variant": "#c5c9ac",
                    "tertiary-fixed": "#e2e2e2",
                    "surface-bright": "#3a3939",
                    "primary": "#ffffff",
                    "surface": "#131313",
                    "on-secondary-container": "#00285c",
                    "tertiary-container": "#e2e2e2",
                    "outline": "#8f9378",
                    "secondary-fixed": "#d8e2ff",
                    "outline-variant": "#444932",
                    "primary-container": "#caf300",
                    "tertiary": "#ffffff",
                    "on-tertiary-container": "#636565"
            },
            "borderRadius": {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
            },
            "spacing": {
                    "unit": "8px",
                    "section-gap": "80px",
                    "component-gap": "16px",
                    "gutter": "24px",
                    "container-margin-desktop": "40px",
                    "container-margin-mobile": "20px"
            },
            "fontFamily": {
                    "headline-lg": ["Inter"],
                    "body-md": ["Inter"],
                    "label-sm": ["JetBrains Mono"],
                    "label-md": ["JetBrains Mono"],
                    "display-lg-mobile": ["Inter"],
                    "display-lg": ["Inter"],
                    "headline-md": ["Inter"],
                    "body-lg": ["Inter"]
            },
            "fontSize": {
                    "headline-lg": ["32px", {"lineHeight": "40px", "letterSpacing": "-0.02em", "fontWeight": "700"}],
                    "body-md": ["16px", {"lineHeight": "24px", "letterSpacing": "0", "fontWeight": "400"}],
                    "label-sm": ["12px", {"lineHeight": "16px", "letterSpacing": "0.08em", "fontWeight": "500"}],
                    "label-md": ["14px", {"lineHeight": "20px", "letterSpacing": "0.05em", "fontWeight": "500"}],
                    "display-lg-mobile": ["40px", {"lineHeight": "48px", "letterSpacing": "-0.02em", "fontWeight": "800"}],
                    "display-lg": ["64px", {"lineHeight": "72px", "letterSpacing": "-0.04em", "fontWeight": "800"}],
                    "headline-md": ["24px", {"lineHeight": "32px", "letterSpacing": "-0.01em", "fontWeight": "700"}],
                    "body-lg": ["18px", {"lineHeight": "28px", "letterSpacing": "0", "fontWeight": "400"}]
            }
          },
        },
      }
    </script>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body-md selection:bg-primary-fixed selection:text-on-primary-fixed">
<!-- TopAppBar -->
<header class="fixed top-0 w-full z-50 bg-background/80 backdrop-blur-xl border-b border-white/10 shadow-[0_20px_40px_rgba(0,0,0,0.5)] flex justify-between items-center px-gutter h-16">
<div class="flex items-center gap-4">
<span class="material-symbols-outlined text-primary-fixed cursor-pointer active:scale-95 transition-transform">bolt</span>
<h1 class="font-display-lg-mobile text-display-lg-mobile italic tracking-tighter text-primary-fixed">VELOCITY AI</h1>
</div>
<div class="flex items-center gap-6">
<nav class="hidden md:flex gap-8 items-center">
<a class="font-label-md text-label-md text-primary-fixed" href="#">Library</a>
<a class="font-label-md text-label-md text-on-surface-variant hover:text-white transition-colors" href="#">Progress</a>
<a class="font-label-md text-label-md text-on-surface-variant hover:text-white transition-colors" href="#">Community</a>
</nav>
<span class="material-symbols-outlined text-on-surface-variant hover:opacity-80 transition-opacity cursor-pointer">notifications</span>
</div>
</header>
<!-- Side Navigation (Desktop) -->
<aside class="hidden md:flex flex-col py-8 px-4 gap-4 h-full w-72 fixed left-0 top-16 z-40 bg-surface-container/70 backdrop-blur-2xl border-r border-white/10 shadow-2xl">
<div class="flex items-center gap-3 mb-8 px-2">
<img alt="Alex Rivers" class="w-12 h-12 rounded-full object-cover border-2 border-primary-fixed" data-alt="A professional fitness athlete with a focused expression, captured in a high-contrast cinematic portrait. The lighting is dramatic and moody, utilizing deep shadows and vibrant lime green rim lights that reflect the Velocity AI brand colors. The athlete is in peak physical condition, emphasizing muscular definition and elite performance aesthetics." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBVH6dTEizEnceUF58YZG1zpaFbIobox-lMaBy_dWpgcKv6uYg7G7UsyJA7JiOhESW3wEhTaI5n4dwAA472CNSMMEqWBVbnFFT6yMMRhHyZtmRINYreeCYE821HP2BGLIQzBOoyJWcalOMyp-thxv5RlJNlNr_LwDOU7gsYZMYOfymMWuRvuvW-geUyn1NaBgI5gyJRd2PzgCMS9Uz1fXYsqQb-EZjBqUZF-XreTdtkzgg1zaEqPNLup3rocTJMuO9kPzQc2XEFPKM"/>
<div>
<p class="font-headline-md text-[18px] text-white">Alex Rivers</p>
<p class="font-label-sm text-label-sm text-on-surface-variant">Level 42 · Pro</p>
</div>
</div>
<div class="space-y-1">
<div class="flex items-center gap-4 py-3 px-4 rounded-lg bg-primary-container/20 text-primary-fixed border-r-4 border-primary-fixed cursor-pointer">
<span class="material-symbols-outlined">fitness_center</span>
<span class="font-label-md text-label-md">Training</span>
</div>
<div class="flex items-center gap-4 py-3 px-4 rounded-lg text-on-surface-variant hover:bg-white/5 hover:text-white transition-all cursor-pointer">
<span class="material-symbols-outlined">dashboard</span>
<span class="font-label-md text-label-md">Dashboard</span>
</div>
<div class="flex items-center gap-4 py-3 px-4 rounded-lg text-on-surface-variant hover:bg-white/5 hover:text-white transition-all cursor-pointer">
<span class="material-symbols-outlined">monitoring</span>
<span class="font-label-md text-label-md">Analytics</span>
</div>
<div class="flex items-center gap-4 py-3 px-4 rounded-lg text-on-surface-variant hover:bg-white/5 hover:text-white transition-all cursor-pointer">
<span class="material-symbols-outlined">group</span>
<span class="font-label-md text-label-md">Members</span>
</div>
<div class="flex items-center gap-4 py-3 px-4 rounded-lg text-on-surface-variant hover:bg-white/5 hover:text-white transition-all cursor-pointer">
<span class="material-symbols-outlined">settings</span>
<span class="font-label-md text-label-md">Settings</span>
</div>
</div>
</aside>
<!-- Main Content -->
<main class="pt-24 pb-32 md:pl-80 px-gutter min-h-screen">
<!-- Search & Filter Header -->
<section class="mb-component-gap">
<div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
<div>
<h2 class="font-headline-lg text-headline-lg text-white mb-2">Exercise Library</h2>
<p class="font-body-md text-on-surface-variant">1,240+ professional drills powered by Velocity AI.</p>
</div>
<div class="relative w-full md:w-96">
<span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
<input class="w-full bg-surface-container-low text-white py-3 pl-12 pr-4 rounded-xl border-none focus:ring-1 focus:ring-primary-fixed outline-none transition-all placeholder:text-on-surface-variant/50" placeholder="Search exercises (e.g. Bench Press)" type="text"/>
</div>
</div>
</section>
<!-- Categories Scroller -->
<section class="flex gap-3 overflow-x-auto pb-4 no-scrollbar mb-8">
<button class="px-6 py-2 rounded-full bg-primary-fixed text-on-primary-fixed font-label-md text-label-md whitespace-nowrap active:scale-95 transition-transform">All</button>
<button class="px-6 py-2 rounded-full glass-card text-white font-label-md text-label-md whitespace-nowrap hover:bg-white/10 active:scale-95 transition-transform">Chest</button>
<button class="px-6 py-2 rounded-full glass-card text-white font-label-md text-label-md whitespace-nowrap hover:bg-white/10 active:scale-95 transition-transform">Legs</button>
<button class="px-6 py-2 rounded-full glass-card text-white font-label-md text-label-md whitespace-nowrap hover:bg-white/10 active:scale-95 transition-transform">HIIT</button>
<button class="px-6 py-2 rounded-full glass-card text-white font-label-md text-label-md whitespace-nowrap hover:bg-white/10 active:scale-95 transition-transform">Core</button>
<button class="px-6 py-2 rounded-full glass-card text-white font-label-md text-label-md whitespace-nowrap hover:bg-white/10 active:scale-95 transition-transform">Back</button>
<button class="px-6 py-2 rounded-full glass-card text-white font-label-md text-label-md whitespace-nowrap hover:bg-white/10 active:scale-95 transition-transform">Shoulders</button>
</section>
<!-- Bento Grid Library -->
<div class="grid grid-cols-1 md:grid-cols-12 gap-component-gap">
<!-- Featured Exercise (Large Card) -->
<div class="md:col-span-8 group relative overflow-hidden rounded-2xl glass-card aspect-video md:aspect-auto h-[400px] cursor-pointer">
<img alt="Deadlift anatomy" class="absolute inset-0 w-full h-full object-cover opacity-60 group-hover:scale-105 transition-transform duration-700" data-alt="A cinematic wide shot of a high-tech gym environment with dark obsidian surfaces and neon lime accents. A muscular athlete is performing a perfect deadlift. Superimposed over the athlete is a translucent, glowing blue anatomical overlay showing the activated muscles in the back and legs. The lighting is atmospheric with soft refractive glows, creating a premium, data-driven training atmosphere." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBH7dn5FwvWPN2rVPMSz4QEuSHgQmvtjiskVmEfSRrR3h8CaxXZ5rKNbwJ3Gb6ZUOwzrQ2IGstI1u_2eGG-WnGfUubnnP1ABYZU4dZ_WRu545XiaP2havT-mfnCbO4aKReTwFHgGIBodFTxzpKHON0dcOhL7DBgUBRaT3QavPvShI1f6_6Kba2BreUSbsSXPPa7xKryJsScaG8vT9PFUrUVoZ_N_Ql_FQGfqq34ht8dts8UFzWbP7uYLYYuddUwoFlLO23whGwR6M4"/>
<div class="absolute inset-0 bg-gradient-to-t from-background via-background/20 to-transparent"></div>
<div class="absolute bottom-0 p-8 w-full">
<div class="flex items-center gap-2 mb-2">
<span class="bg-primary-fixed text-on-primary-fixed px-3 py-1 rounded text-[10px] font-bold tracking-widest uppercase">Expert Pick</span>
<span class="text-on-surface-variant font-label-sm text-label-sm">High Intensity</span>
</div>
<h3 class="font-display-lg-mobile text-display-lg-mobile text-white leading-none mb-2">Conventional Deadlift</h3>
<p class="text-on-surface-variant max-w-lg mb-6">The ultimate full-body compound movement. Master the hip hinge and build raw explosive power.</p>
<div class="flex gap-4">
<button class="px-6 py-3 bg-primary-fixed text-on-primary-fixed rounded-lg font-bold uppercase tracking-wider text-label-md primary-glow flex items-center gap-2 transition-all">
<span class="material-symbols-outlined text-[20px]">play_circle</span> Watch Form
                        </button>
<button class="px-6 py-3 glass-card text-white rounded-lg font-bold uppercase tracking-wider text-label-md hover:bg-white/10 transition-all">Anatomy View</button>
</div>
</div>
</div>
<!-- Side Stats/AI Insight -->
<div class="md:col-span-4 glass-card rounded-2xl p-6 flex flex-col justify-between">
<div>
<div class="flex items-center gap-2 mb-4">
<span class="material-symbols-outlined text-primary-fixed">smart_toy</span>
<h4 class="font-headline-md text-[18px] text-white">AI Muscle Map</h4>
</div>
<div class="space-y-4">
<div class="flex justify-between items-end">
<span class="text-on-surface-variant font-label-md">Hamstrings</span>
<span class="text-primary-fixed font-label-md">98%</span>
</div>
<div class="h-1.5 bg-white/5 rounded-full overflow-hidden">
<div class="h-full bg-primary-fixed w-[98%] shadow-[0_0_10px_rgba(202,243,0,0.5)]"></div>
</div>
<div class="flex justify-between items-end">
<span class="text-on-surface-variant font-label-md">Lower Back</span>
<span class="text-secondary font-label-md">85%</span>
</div>
<div class="h-1.5 bg-white/5 rounded-full overflow-hidden">
<div class="h-full bg-secondary w-[85%]"></div>
</div>
<div class="flex justify-between items-end">
<span class="text-on-surface-variant font-label-md">Glutes</span>
<span class="text-primary-fixed font-label-md">92%</span>
</div>
<div class="h-1.5 bg-white/5 rounded-full overflow-hidden">
<div class="h-full bg-primary-fixed w-[92%] shadow-[0_0_10px_rgba(202,243,0,0.5)]"></div>
</div>
</div>
</div>
<div class="mt-8 pt-8 border-t border-white/10">
<p class="font-label-sm text-label-sm text-on-surface-variant mb-3 uppercase tracking-widest">AI Tip</p>
<p class="text-white text-body-md italic font-light leading-relaxed">"Keep your lats engaged by imagining you are squeezing oranges under your armpits. This secures the spine."</p>
</div>
</div>
<!-- Common Mistakes Card -->
<div class="md:col-span-4 glass-card rounded-2xl p-6">
<div class="flex items-center justify-between mb-6">
<h4 class="text-white font-headline-md text-[18px]">Form Correction</h4>
<span class="material-symbols-outlined text-error">report</span>
</div>
<ul class="space-y-4">
<li class="flex items-start gap-4">
<div class="w-2 h-2 rounded-full bg-error mt-2"></div>
<div>
<p class="text-white font-label-md">Rounding the Spine</p>
<p class="text-on-surface-variant text-[12px]">Risk of lumbar disc herniation.</p>
</div>
</li>
<li class="flex items-start gap-4">
<div class="w-2 h-2 rounded-full bg-error mt-2"></div>
<div>
<p class="text-white font-label-md">Hyperextending at Top</p>
<p class="text-on-surface-variant text-[12px]">Unnecessary compression on facets.</p>
</div>
</li>
</ul>
<div class="mt-6 p-4 rounded-xl bg-error/10 border border-error/20">
<p class="text-error font-label-sm text-[11px] uppercase tracking-widest mb-1">Avoid</p>
<p class="text-white text-[13px]">Bouncing the plates off the floor.</p>
</div>
</div>
<!-- AI Suggested Alternatives -->
<div class="md:col-span-8 glass-card rounded-2xl p-6">
<div class="flex items-center justify-between mb-6">
<h4 class="text-white font-headline-md text-[18px]">AI Progression Path</h4>
<span class="material-symbols-outlined text-secondary">trending_up</span>
</div>
<div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
<div class="p-4 rounded-xl bg-white/5 border border-white/5 hover:border-primary-fixed/30 transition-all cursor-pointer group">
<p class="text-on-surface-variant font-label-sm mb-2 uppercase tracking-tighter">Regressive</p>
<p class="text-white font-headline-md text-[16px] mb-4 group-hover:text-primary-fixed transition-colors">Kettlebell RDL</p>
<span class="material-symbols-outlined text-[18px] text-on-surface-variant">arrow_forward</span>
</div>
<div class="p-4 rounded-xl bg-white/5 border border-primary-fixed/50 transition-all cursor-pointer group relative overflow-hidden">
<div class="absolute top-0 right-0 p-1 bg-primary-fixed text-on-primary-fixed text-[8px] font-bold">CURRENT</div>
<p class="text-on-surface-variant font-label-sm mb-2 uppercase tracking-tighter">Current</p>
<p class="text-white font-headline-md text-[16px] mb-4">BB Deadlift</p>
<span class="material-symbols-outlined text-[18px] text-primary-fixed">check_circle</span>
</div>
<div class="p-4 rounded-xl bg-white/5 border border-white/5 hover:border-primary-fixed/30 transition-all cursor-pointer group">
<p class="text-on-surface-variant font-label-sm mb-2 uppercase tracking-tighter">Progressive</p>
<p class="text-white font-headline-md text-[16px] mb-4 group-hover:text-primary-fixed transition-colors">Deficit Deadlift</p>
<span class="material-symbols-outlined text-[18px] text-on-surface-variant">bolt</span>
</div>
</div>
</div>
<!-- List of other exercises -->
<div class="md:col-span-12 mt-8">
<h4 class="font-headline-md text-headline-md text-white mb-6">Chest &amp; Shoulders</h4>
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-component-gap">
<!-- Exercise Small Card 1 -->
<div class="glass-card rounded-2xl overflow-hidden group cursor-pointer hover:translate-y-[-4px] transition-all">
<div class="h-40 overflow-hidden relative">
<img alt="Bench press" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" data-alt="A close-up action shot of a professional bench press performance. The focus is on the chest and shoulder muscles, which are highlighted by sharp, dramatic studio lighting. The background is a dark, sleek gym environment with subtle lens flares from high-end lighting equipment. The overall aesthetic is clean, athletic, and high-performance." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBLyvhaMExsyCUdCVEBOJXFIMehLrYJQvG-lWPy0LX12u2bUyL9iCzmhMPFagEJRtqVXRr_jwNPaziVM4qAhso3XOdGJoarxpDX0985wSSy2pOqLwPTrVIK7C7nraPR3A-EFAtNkgMsyEAv5ZFXIHJv7Kb1PxrZOWB4eUqhACoSmISEiz7RnFsA5Yjb6JSSvxZIX4TkD2ALAqwFvMXunGba7IG9iNf9I_IrwoR-5s9IucIqx58uUvKzVNjtNDhngOb1Snv6EsvS0kE"/>
<div class="absolute top-3 left-3 px-2 py-1 bg-background/80 backdrop-blur-md rounded text-[10px] font-bold text-white uppercase">Intermediate</div>
</div>
<div class="p-4">
<h5 class="text-white font-headline-md text-[16px]">Bench Press</h5>
<p class="text-on-surface-variant text-[12px] mb-4">Pectoralis Major, Triceps</p>
<div class="flex justify-between items-center">
<span class="text-primary-fixed text-[12px] font-bold">4 Videos</span>
<span class="material-symbols-outlined text-[20px] text-on-surface-variant group-hover:text-primary-fixed">add_circle</span>
</div>
</div>
</div>
<!-- Exercise Small Card 2 -->
<div class="glass-card rounded-2xl overflow-hidden group cursor-pointer hover:translate-y-[-4px] transition-all">
<div class="h-40 overflow-hidden relative">
<img alt="Overhead Press" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" data-alt="A high-intensity workout scene of a person performing an overhead shoulder press. The lighting is harsh and directional, emphasizing the peak contraction of the deltoid muscles. The setting is an industrial-style elite gym with dark concrete walls and glowing lime green branding elements. The mood is powerful and focused." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCAm_GTSamQ7nt803VdK3sh5_82vNQWnyLCTYm4Xbg7Kg2Mu7QeBqTODzbiHrE26q2gwMfnkeUSwbdYcherBYT6AnHBy0reobQYCLfi6ohonRRCUbXAmLJuNwB1X3D0QfCg_S9efTwE4wl8WIRWDcWcXnTyJir15Om46uRwz29JyK61DphJ6H0nnZNlSeSLicLz9NTC0Z7w4MxJDhpRj6HcV_H9fnPLWBKGBINaRW3lO6s8jO2-H3dCill9Cryey0isCoEx4AvWH0o"/>
<div class="absolute top-3 left-3 px-2 py-1 bg-background/80 backdrop-blur-md rounded text-[10px] font-bold text-white uppercase">Advanced</div>
</div>
<div class="p-4">
<h5 class="text-white font-headline-md text-[16px]">Overhead Press</h5>
<p class="text-on-surface-variant text-[12px] mb-4">Deltoids, Trapezius</p>
<div class="flex justify-between items-center">
<span class="text-primary-fixed text-[12px] font-bold">2 Videos</span>
<span class="material-symbols-outlined text-[20px] text-on-surface-variant group-hover:text-primary-fixed">add_circle</span>
</div>
</div>
</div>
<!-- Exercise Small Card 3 -->
<div class="glass-card rounded-2xl overflow-hidden group cursor-pointer hover:translate-y-[-4px] transition-all">
<div class="h-40 overflow-hidden relative">
<img alt="Incline Flyes" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" data-alt="A fitness enthusiast performing incline dumbbell flyes in a futuristic training center. The shot uses a shallow depth of field, blurring the high-tech equipment in the background. Vivid lime green lights reflect off the chrome dumbbells and the athlete's skin. The lighting is high-contrast obsidian with glowing highlights, showcasing technical precision." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCWa_jBRGEq5TS2OqAd0thcXQgK2fcCK4y_KZaMq2502XK3E6YQose5otd6-kigHzS2Re70cowC7st9md6BcF1XsfGIJEjFRRw8yOwiEj5Rdm1OddvZ3mUPZNTB5PpHOMm4FSDnDFd_LThoiu4F-6Dc4EAp0vNfEpQE3Cyzx7CEyQwecvgasiki8viIecyh6sdIE0PWcaqPfS5fccpcw1VPD8wH0YVrkynp9np0xxNzG9rxapYTMM8HrNDTBQ2mmc6q-upW0IFPl3k"/>
<div class="absolute top-3 left-3 px-2 py-1 bg-background/80 backdrop-blur-md rounded text-[10px] font-bold text-white uppercase">Intermediate</div>
</div>
<div class="p-4">
<h5 class="text-white font-headline-md text-[16px]">Incline Flyes</h5>
<p class="text-on-surface-variant text-[12px] mb-4">Upper Chest, Delts</p>
<div class="flex justify-between items-center">
<span class="text-primary-fixed text-[12px] font-bold">3 Videos</span>
<span class="material-symbols-outlined text-[20px] text-on-surface-variant group-hover:text-primary-fixed">add_circle</span>
</div>
</div>
</div>
<!-- Exercise Small Card 4 -->
<div class="glass-card rounded-2xl overflow-hidden group cursor-pointer hover:translate-y-[-4px] transition-all">
<div class="h-40 overflow-hidden relative">
<img alt="Dips" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" data-alt="An athlete performing tricep dips on parallel bars in a gritty, high-performance gym environment. The lighting is dramatic and moody, utilizing deep shadows and vibrant lime green rim lights. The focus is on the intense muscular engagement of the triceps and chest. The environment feels professional and elite." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCXTq1Lc8PSYYO0xAhdSgpzZYWDvMU_aAfH6TplT_hJY08ylvMqWjdbJ7u49cl4Qhb1BLnxAuyp_aEAo86CoFvgg29Tay-J-zzKEZqmvDMOK3JS620OkHHQ2KsVaexuyfn9RYu_wfT50bhYZU6v-l9Cf-SKUgk8NBJGr7GHCWepOz1QJmkXrNj8jr8aa_hL1yjsC-Dow2Iau-igLDDI_VwZTaK5nXSCEusjRc_nHIcyC0tlcw7TYQ3HUWnP_tBpBFgZ0pJyB67_AZk"/>
<div class="absolute top-3 left-3 px-2 py-1 bg-background/80 backdrop-blur-md rounded text-[10px] font-bold text-white uppercase">Beginner</div>
</div>
<div class="p-4">
<h5 class="text-white font-headline-md text-[16px]">Weighted Dips</h5>
<p class="text-on-surface-variant text-[12px] mb-4">Triceps, Lower Chest</p>
<div class="flex justify-between items-center">
<span class="text-primary-fixed text-[12px] font-bold">5 Videos</span>
<span class="material-symbols-outlined text-[20px] text-on-surface-variant group-hover:text-primary-fixed">add_circle</span>
</div>
</div>
</div>
</div>
</div>
</div>
</main>
<!-- Bottom Navigation Bar (Mobile) -->
<nav class="md:hidden fixed bottom-0 w-full rounded-t-xl z-50 bg-surface-container-lowest/80 backdrop-blur-3xl border-t border-white/10 shadow-[0_-10px_30px_rgba(0,0,0,0.3)] flex justify-around items-center h-20 px-2">
<div class="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary-fixed active:scale-90 duration-150 cursor-pointer">
<span class="material-symbols-outlined">home</span>
<span class="font-label-sm text-label-sm">Home</span>
</div>
<div class="flex flex-col items-center justify-center text-primary-fixed relative after:content-[''] after:absolute after:-bottom-1 after:w-1 after:h-1 after:bg-primary-fixed after:rounded-full active:scale-90 duration-150 cursor-pointer">
<span class="material-symbols-outlined">exercise</span>
<span class="font-label-sm text-label-sm">Library</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary-fixed active:scale-90 duration-150 cursor-pointer">
<span class="material-symbols-outlined">smart_toy</span>
<span class="font-label-sm text-label-sm">AI Buddy</span>
</div>
<div class="flex flex-col items-center justify-center text-on-surface-variant hover:text-primary-fixed active:scale-90 duration-150 cursor-pointer">
<span class="material-symbols-outlined">equalizer</span>
<span class="font-label-sm text-label-sm">Stats</span>
</div>
</nav>
<!-- Floating Action Button -->
<div class="fixed right-6 bottom-24 md:bottom-8 z-40 group">
<button class="w-14 h-14 bg-primary-fixed text-on-primary-fixed rounded-full shadow-2xl flex items-center justify-center primary-glow active:scale-95 transition-all">
<span class="material-symbols-outlined">add</span>
</button>
<div class="absolute bottom-full right-0 mb-4 flex flex-col gap-2 scale-0 group-hover:scale-100 origin-bottom transition-all duration-200">
<button class="px-4 py-2 glass-card text-white text-[12px] rounded-lg whitespace-nowrap">Create Workout</button>
<button class="px-4 py-2 glass-card text-white text-[12px] rounded-lg whitespace-nowrap">Log Exercise</button>
</div>
</div>
<script>
        // Micro-interactions and atmospheric effects
        document.addEventListener('DOMContentLoaded', () => {
            const cards = document.querySelectorAll('.glass-card');
            
            cards.forEach(card => {
                card.addEventListener('mousemove', (e) => {
                    const rect = card.getBoundingClientRect();
                    const x = e.clientX - rect.left;
                    const y = e.clientY - rect.top;
                    
                    card.style.setProperty('--mouse-x', `${x}px`);
                    card.style.setProperty('--mouse-y', `${y}px`);
                });
            });

            // Smooth Scroll for category bar
            const categoryBar = document.querySelector('.no-scrollbar');
            if(categoryBar) {
                categoryBar.addEventListener('wheel', (evt) => {
                    evt.preventDefault();
                    categoryBar.scrollLeft += evt.deltaY;
                });
            }
        });
    </script>
</body></html>