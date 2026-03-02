#  Météo Mondiale — L3GL ISI 2026

Application Flutter météo ultra stylée avec glassmorphism, animations premium et carte interactive.

## 👥 Membres du groupe

| Nom | Prénom | Matricule |
|-----|--------|-----------|
|Seydina mouhamed   Ndiaye |
|sokhna   Bousso   wagnane |
| Aboubacar Hamet  Diallo 

##Lancer l'application

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Lancer en mode debug
flutter run

# 3. Builder pour Android
flutter build apk --release
```

## 📱 Fonctionnalités

### 🏠 Écran d'accueil
- Globe terrestre animé avec méridiens rotatifs
- Animations d'entrée staggerées
- Toggle dark/light mode fluide
- Chips des 5 villes avec drapeaux
- Bouton CTA avec effet shimmer

### 📊 Écran de chargement
- Jauge circulaire avec double anneau rotatif + neon glow
- Fond qui change de couleur progressivement (0% → 100%)
- Messages d'attente animés en fondu
- Liste des 5 villes avec ✓ vert animé
- Compteur % smooth animé

### 🗺️ Dashboard des villes
- Cards avec image de fond floue selon condition météo
- Glassmorphism par-dessus
- Température large + condition météo
- Chips humidité + vent
- Bouton "Recommencer" avec effet pulse

### 🏙️ Détail ville
- Photo de fond via Unsplash selon condition météo
- Icône météo levitante (animation loop)
- Badges rapides : Ressenti / Max / Min
- Grille 3×2 de stats avec accent bars colorées
- Arc solaire animé avec position du soleil en temps réel
- **Carte OpenStreetMap intégrée** (ZÉRO clé API requise !)
  - Mode dark ou light selon le thème
  - Badge flottant ville + température
  - Boutons zoom custom design

## 🛠️ Architecture

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart      # Charte graphique + helpers météo
├── data/
│   ├── models/
│   │   └── weather_model.dart  # Modèle + mock data
│   └── repositories/
│       └── weather_repository.dart  # Appels API OpenWeather
├── domain/
│   └── entities/
│       └── weather_entity.dart  # Entité métier
├── presentation/
│   ├── providers/
│   │   └── weather_provider.dart  # State management (Provider)
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── loading_screen.dart
│   │   ├── dashboard_screen.dart
│   │   └── city_detail_screen.dart
│   └── widgets/
│       └── shared_widgets.dart  # Widgets réutilisables
└── main.dart
```

## Carte — Zéro clé API !

| Outil | Rôle | Prix |
|-------|------|------|
| `flutter_map` | Affiche la carte dans Flutter | Gratuit |
| OpenStreetMap | Fournit les images de la carte | Gratuit |
| `latlong2` | Gère les coordonnées GPS | Gratuit |

Les coordonnées GPS viennent directement de l'API OpenWeather.

##  API

- **OpenWeatherMap** : `https://api.openweathermap.org/data/2.5/weather`
- **Langue** : Français (`lang=fr`)
- **Unités** : Métriques (`units=metric`)
- **Fallback** : Mock data réaliste si API indisponible

##  Design

### Dark Mode
- Fond : `#050510`
- Accent : `#00FFD1` (cyan néon)
- Purple : `#B44FFF`

### Light Mode
- Fond : `#F5F7FF`
- Accent : `#006B54`
- Purple : `#5B21B6`

##  Dépendances

```yaml
dio: ^5.4.0              # HTTP
provider: ^6.1.1         # State management
flutter_map: ^6.1.0      # Carte (gratuit)
latlong2: ^0.9.0         # Coordonnées GPS
google_fonts: ^6.1.0     # Typographie
cached_network_image: ^3.3.1  # Images
shimmer: ^3.0.0          # Effet shimmer
intl: ^0.19.0            # Formatage dates
```
