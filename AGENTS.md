# MD22 working notes

- Reuse a dedicated DerivedData directory for local Xcode builds.
- After creating a new build, remove superseded build directories, archives,
  and temporary test app copies created during the task. Check what each path
  contains before deleting it.
- Keep the current build under test, the newest deliverable, installed apps,
  notarized release artifacts, and anything the user asked to retain. Never
  delete unrelated files or another contributor's work.
- Quit disposable MD22 test app instances when testing is finished.
