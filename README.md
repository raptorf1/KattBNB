[![Coverage Status](https://coveralls.io/repos/github/raptorf1/KattBNB_API/badge.svg?branch=development)](https://coveralls.io/github/raptorf1/KattBNB_API?branch=development)
[![Build Status](https://semaphoreci.com/api/v1/raptorf1/kattbnb_api/branches/development/badge.svg)](https://semaphoreci.com/raptorf1/kattbnb_api)


# Project Title

## **KattBNB**
### **Cat boarding made easy !**
*While there are plenty of services targeted for dogs, cat owners are left to suit for themselves when the holiday season starts. Cats are known to be anxious travelers and are less likely to accompany their owners even during
short domestic trips. Often it is friends and family members taking on the pet sitting duty, yet it is not a reliable solution during summer season when most swedes try to escape the city themselves. Pet boarding centers and hotels are expensive and get fully booked quickly. Individual pet sitters
offer home visits, although it is a poor solution for longer periods of time.
There is no single service that solves “But what about the cat?” problem, when
cat owners are going away for more than couple of days.*

*KattBNB is an online peer-to-peer marketplace, that lets cat sitters offer their services and cat owners pick a pet sitter that is nearest or in other ways most convenient to them.*

# User Stories

Check out the development progress in [this](https://www.pivotaltracker.com/n/projects/2376676) Pivotal Tracker board.

# Deployment & GitHub

This application consists of a back-end API and a front-end Client.

The GitHub repository for the API is [here](https://github.com/raptorf1/KattBNB_API) and the one for the Client is [here](https://github.com/zanenkn/KattBNB_client).

The application is deployed on Netlify [here](https://kattbnb.netlify.com/).

# Tests, Test Coverage & CI

### API
The API part of the application was request and unit tested using [Rspec](https://rspec.info/).

To be able to run the tests, run `bundle install` in your terminal as soon as you fork this repository.

You must also have the database migrations in place, in order for everything to work properly. So in your terminal run `rails db:migrate`. In case this command produces an error, you can run `rails db:drop db:setup`.

After that, use `bundle exec rspec` to run all tests avoiding any conflicts with the gems of this repo and your locally installed gems.

Unit and request tests can be found in the `spec/models` and `spec/requests` folders respectively.

[Coveralls](https://coveralls.io/) was used to measure the API's test coverage.

[Semaphore CI](https://semaphoreci.com/) was used for continious integration.

### CLIENT
The Client part of the application was acceptance tested using [Cypress](https://www.cypress.io/).

All API calls are handled using mock data `json` files, which can be found in the `cypress/fixtures` folder. Before you run any tests, you first need to asssign the `development` value to `axios.defaults.baseURL` and `authUrl` variables found in `src/index.js` and  `src/reduxTokenAuthConfig.js` respectively. Then you run `npm install` in your terminal to download all packages.

After that, use `npm run cy:open` to launch a local server instance of the application and run all acceptance tests of Cypress.

Acceptance tests can be found in the `cypress/integration` folder.

# Built With

* API with [Ruby on Rails](https://rubyonrails.org/) version 5.2.3.
* API with [Ruby](https://www.ruby-lang.org/en/) version 2.4.1.
* Client with [React](https://reactjs.org/).
* Client was styled using [Semantic UI](https://react.semantic-ui.com/).
* Client uses [gulp](https://gulpjs.com/) build runner. All relevant files can be found in `src/semantic` folder.

# Authors

* **Zane**- [GitHub Profile](https://github.com/zanenkn) - [Portfolio Website](https://zanenkn.netlify.com/)
* **raptorf1** - [GitHub Profile](https://github.com/raptorf1) - [Portfolio Website](https://gtomaras-portfolio.netlify.com/)

# License

Our intention is to make a business out of this project, so in the near future it will be legally patented. When this happens, we will update this section with further details.

# Contribute / Donate

Some of the expenses involved to turn this project into a sustainable business are:
* Amazon Web Services subscription
* Domain name fees
* Payment solution provider fees
* Accounting services
* Company registration fees

Those of you who are keen to what we are trying to build here and have the resourses or competences to assist us, feel free to contact us at *kattbnb@gmail.com* for a further discussion.

# Acknowledgments

* [PurpleBooth](https://github.com/PurpleBooth) for this README template.
* [Rails Guides](https://guides.rubyonrails.org/index.html) for the detailed documentation.
* [Stack Overflow](https://stackoverflow.com/) for the guidance during the "difficult" times during development.
* [React documentation](https://reactjs.org/docs/getting-started.html) for the support we needed on related issues.
