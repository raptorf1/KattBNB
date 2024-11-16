# Project Title

## **KattBNB**

### **Cat boarding made easy !**

_While there are plenty of services targeted for dogs, cat owners are left to suit for themselves when the holiday season starts. Cats are known to be anxious travelers and are less likely to accompany their owners even during
short domestic trips. Often it is friends and family members taking on the pet sitting duty, yet it is not a reliable solution during summer season when most swedes try to escape the city themselves. Pet boarding centers and hotels are expensive and get fully booked quickly. Individual pet sitters
offer home visits, although it is a poor solution for longer periods of time.
There is no single service that solves “But what about the cat?” problem, when
cat owners are going away for more than couple of days._

_KattBNB is an online peer-to-peer marketplace, that lets cat sitters offer their services and cat owners pick a pet sitter that is nearest or in other ways most convenient to them._

### API

The API part of the application was request and unit tested using [Rspec](https://rspec.info/).

To be able to run the tests, run `bundle install` in your terminal as soon as you fork this repository.

You must also have the database migrations in place, in order for everything to work properly. So in your terminal run `rails db:migrate`. In case this command produces an error, you can run `rails db:drop db:setup`.

After that, use `bundle exec rspec` to run all tests avoiding any conflicts with the gems of this repo and your locally installed gems.

Unit and request tests can be found in the `spec/models` and `spec/requests` folders respectively.

[SimpleCov](https://github.com/simplecov-ruby/simplecov) is used to measure the API's test coverage.

### CLIENT

The Client part of the application was acceptance tested using [Cypress](https://www.cypress.io/).

All API calls are handled using mock data `json` files, which can be found in the `cypress/fixtures` folder. Before you run any tests, execute `npm install` in your terminal to download all packages.

After that, use `npm run cy:open` to launch a local server instance of the application and run all acceptance tests of Cypress.

Acceptance tests can be found in the `cypress/integration` folder.

# Built With

- API with [Ruby on Rails](https://rubyonrails.org/) and [Ruby](https://www.ruby-lang.org/en/).
- Client with [React](https://reactjs.org/).

# Authors

- **Zane**- [GitHub Profile](https://github.com/zanenkn) - [Portfolio Website](https://zanenkn.netlify.com/)
- **raptorf1** - [GitHub Profile](https://github.com/raptorf1)

# Acknowledgments

- [PurpleBooth](https://github.com/PurpleBooth) for this README template.
- [Rails Guides](https://guides.rubyonrails.org/index.html) for the detailed documentation.
- [Stack Overflow](https://stackoverflow.com/) for the guidance during the "difficult" times during development.
- [React documentation](https://reactjs.org/docs/getting-started.html) for the support we needed on related issues.
