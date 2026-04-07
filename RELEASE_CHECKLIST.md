# Release Checklist

## Pre-release
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Confirm provider endpoints are reachable
- [ ] Review app version in `pubspec.yaml`
- [ ] Review Android app name / icon / package id

## Android readiness
- [ ] Android SDK installed and configured
- [ ] `flutter doctor -v` passes critical Android checks
- [ ] `flutter build apk --debug` succeeds
- [ ] Review release signing strategy
- [ ] Confirm `applicationId` is production-ready

## UX checks
- [ ] Home screen summaries load correctly
- [ ] Provider detail pages refresh correctly
- [ ] Error and retry UI behaves correctly
- [ ] Time labels and formatting look correct

## Repo hygiene
- [ ] Commit current phase cleanly
- [ ] Push branch to GitHub
- [ ] Update README if user-facing behavior changed

## Premium / Billing readiness
- [ ] Replace mock purchase service with real billing provider
- [ ] Define product ids for monthly/yearly plans
- [ ] Test upgrade, restore, and expired subscription flows
- [ ] Confirm premium gating matches active subscription state
