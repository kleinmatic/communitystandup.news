# communitystandup.news

The website for the Community Standup project. It is one page.

The text comes from a Google Doc. The link to the Doc is not stored in this repository.
Ask one of the project coordinators for it.

## To update the site

1. Edit the Google Doc.
2. Go to the **Actions** tab of this repository.
3. Select **Publish site** in the left column.
4. Select **Run workflow**, then the green **Run workflow** button.

The site updates in about one minute.

## Rules for the Doc

- Keep the Doc shared as "Anyone with the link can view". The build fails if it is not.
- The first line must use the Title or Heading 1 style. It becomes the page title.
- The first paragraph becomes the description that search engines and link previews show.
- Use Heading 2 for section headings.

## How it works

`build.sh` downloads the Doc as Markdown and converts it to HTML with
[pandoc](https://pandoc.org). `template.html` is the page frame. The design is [Pico CSS](https://picocss.com), which
styles plain HTML with no extra markup. `style.css` holds our few changes on top of it.
The workflow in `.github/workflows/publish.yml` runs the build and publishes the result to
GitHub Pages. No generated files are stored in the repository.

The workflow reads the ID of the Doc from a repository secret named `GOOGLE_DOC_ID`.

To build on your own computer, install pandoc, put the ID of the Doc in a file named
`.doc-id`, and run `./build.sh`. The page is written to `_site/index.html`.
