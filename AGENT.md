# AGENT Manifest for gecco.xyz

This document serves as an agent manifest and high-level guide for understanding and contributing to the gecco.xyz website, which is built using Hugo and the Blowfish theme.

## Project Overview
The gecco.xyz site is a personal portfolio/resume built with Hugo. The core structure and styling are managed by the Blowfish theme.

## Technical Stack
*   **Static Site Generator:** Hugo
*   **Theme:** Blowfish
*   **Configuration:** Global configuration is handled primarily in `gecco.xyz/config/_default/hugo.toml`. Localization is managed in `gecco.xyz/config/_default/languages.en.toml`.

## Documentation and Structure Reference
For detailed instructions on configuration, content creation, and theme customization, refer to the Blowfish theme documentation, which is available at:
`gecco.xyz/themes/blowfish/exampleSite/content/docs`

Key areas documented include:
*   **Getting Started:** Installation and initial setup.
*   **Configuration:** Managing site parameters, including `paginate`, `summaryLength`, and language settings.
*   **Content Examples:** Guidance on structuring different types of content (e.g., pages, shortcodes).
*   **Shortcodes:** Specific usage details for components like galleries, featured items, and custom elements.
*   **Hosting/Deployment:** Instructions for deploying the site to services like GitHub Pages or Netlify.

## Contributing
To make changes:
1.  Understand the required configuration changes (see `hugo.toml`).
2.  Modify content files (e.g., `gecco.xyz/content/resume/index.md`).
3.  Review the Blowfish documentation for specific syntax and structure requirements.

---
*Last updated: [Current Date]*