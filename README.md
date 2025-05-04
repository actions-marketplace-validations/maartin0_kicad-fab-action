# Generate KiCad fabrication files action
Generates fabrication (gerber and drill) files for the provided `.kicad_pcb` file on all layers into a zip

See [this list](https://github.com/stars/maartin0/lists/kicad-action-utils) for related actions

### Example
`.github/workflows/gen-fab.yml`
```yml
name: Generate fabrication files for pull request

on:
  pull_request:
    types:
      - opened
    paths:
      - "**.kicad_pcb"

jobs:
  run:
    runs-on: ubuntu-latest

    permissions:
      contents: write
      pull-requests: read

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Checkout to latest PR commit
        env:
          PR: ${{ github.event.pull_request.url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git config --global --add safe.directory "$(pwd)"
          gh pr checkout "$(echo "$PR" | sed 's/.*\/pulls\///')"

      - name: Generate fabrication files
        uses: maartin0/kicad-fab-action@v1
        with:
          pcb: project_name.kicad_pcb
          output: "fabrication.zip"

      - name: Commit and push changes
        run: |
          git config --global user.name 'github-actions'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'
          git config --global --add safe.directory "$(pwd)"
          git add fabrication.zip
          git commit -m "Generate KiCad fabrication files"
          git push
```
