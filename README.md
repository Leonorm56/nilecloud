<p align="center">
  <img src="https://raw.githubusercontent.com/Leonorm56/NileChain/main/apps/purrfect-farmer/src/assets/images/nilechain-logo.png" alt="NileChain Logo" width="80" height="80">
</p>

<h1 align="center">NileCloud</h1>

<p align="center">
  <strong>Cloud execution engine for NileChain farmers</strong>
</p>

NileCloud is the server-side component of NileChain that runs farmers remotely on a VPS. It executes farming automation for Telegram Mini-Apps using real Telegram sessions and proxy rotation.

## Architecture

- **Fastify 5** HTTP server
- **MySQL** database for accounts, farmers, subscriptions
- **MTProto** Telegram client for session management and initData refresh
- **Axios** + proxy rotation for farmer API calls
- **Cron-based** scheduled farmer execution

## Getting Started

_Coming soon once source code is integrated._

## Structure

```
nilecloud/
├── app.js              # Server entry point
├── farmers/            # Farmer runner classes
├── routes/             # API routes
├── plugins/            # Fastify plugins
├── lib/                # Utilities
├── db/                 # Database models & migrations
└── cron.js             # Scheduled task runner
```

## License

MIT
