# rice_guard

A new Flutter project.

## Run (Dev)

```bash
flutter run \
  --dart-define=ENV=dev \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

API calls target the versioned backend routes (`/api/v1/*`).

## Branding

- Shared icon source: `../branding/app_icon.svg`
- Android launcher icon: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Mobile master PNG asset: `assets/images/app_icon.png`

## Display Settings

Open the tune icon on the home app bar to change:

- Light / dark / system theme
- Font size
- Font family
