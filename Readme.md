## arXiv paper checking bot

A bot watching arXiv papers that matches your keywords.
When this bot find papers that matches your keywords, it can notifies you via Gmail or slack.

### Get started (on Heroku)

1. Git clone this repository
1. Edit `settings.yml` and commit it

    Change keywords to what you like. You can list multiple keywords as follows.

        - NILM
        - Deep Learning

    Some prefix has special meanings
    - "+" means OR

      `+Energy` is converted to `+OR+Energy`

    - "!" means ANDNOT

      `!FHHM` is converted to `+ANDNOT+FHHM`

    Please refer to section 5.1 of [https://arxiv.org/help/api/user-manual](https://arxiv.org/help/api/user-manual) for details of these keywords.

1. Create heroku application
    ```
    $ heroku create your_app_name
    $ git push heroku master
    ```
1. Check addons (postgres)
    ```
    $ heroku addons
    ```
    Make sure you have `heroku-postgresql`

    If you don't have it, you can add addon by `$ heroku addons:create heroku-postgresql:hobby-dev`
1. Check `DATABASE_URL`
    ```
    $ heroku config
    DATABASE_URL: postgres://...
    ```

1. Create DB tables
    ```
    $ heroku run ruby init_db.rb
    ```

1. Set credentials as environment variables
    ```
    $ heroku config:set ARXIV_BOT_GMAIL_USERNAME=xxx@gmail.com
    $ heroku config:set ARXIV_BOT_GMAIL_PASSWORD=xxx
    $ heroku config:set ARXIV_BOT_GMAIL_FROM=xxx@gmail.com
    $ heroku config:set ARXIV_BOT_GMAIL_TO=yyy@gmail.com
    $ heroku config:set ARXIV_BOT_SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxxxx
    ```

1. Add scheduler addon
    ```
    $ heroku addons:create scheduler:standard
    ```
1. Add job
    ```
    $ heroku addons:open scheduler
    ```
    Click 'Add new job'

    Type `$ ruby bot.rb` into textbox

    Save it


Now, preparation is all done. Wait for new papers.
