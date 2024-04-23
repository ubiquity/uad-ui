import { OAuthToken } from "../../static/scripts/onboarding/github-login-button";

describe("Homepage tests", () => {
  const ORG_NAME = "Ubiquity";
  let loginToken: OAuthToken;

  beforeEach(() => {
    cy.fixture("get-user.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/users/${ORG_NAME}`, (req) => {
        req.reply(file);
      }).as("githubGetUser");
    });
    cy.fixture("get-ubiquibot-config.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/repos/${ORG_NAME}/ubiquibot-config`, (req) => {
        req.reply(file);
      }).as("githubGetUbiquibotConfig");
    });
    cy.fixture("get-repos.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/orgs/${ORG_NAME}/repos`, (req) => {
        req.reply(file);
      }).as("githubGetRepos");
    });
    cy.fixture("get-installations.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/orgs/${ORG_NAME}/installations**`, (req) => {
        req.reply(file);
      }).as("githubGetInstallations");
    });
    cy.fixture("get-installation-repositories.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/user/installations/47252474/repositories`, (req) => {
        req.reply(file);
      }).as("githubGetInstallationRepositories");
    });
    cy.fixture("put-file.json").then((file) => {
      cy.intercept("PUT", `https://api.github.com/user/installations/47252474/repositories/641336624`, (req) => {
        req.reply(file);
      }).as("githubPutInstallation");
    });
    cy.fixture("put-file.json").then((file) => {
      cy.intercept("PUT", `https://api.github.com/repos/${ORG_NAME}/ubiquibot-config/contents/.github%2Fubiquibot-config.yml`, (req) => {
        req.reply(file);
      }).as("githubPutConfigFile");
    });
    cy.fixture("get-orgs.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/user/orgs**`, (req) => {
        req.reply(file);
      }).as("githubGetUserOrgs");
    });
    cy.fixture("get-org-installations.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/orgs/${ORG_NAME.toLowerCase()}/installations**`, (req) => {
        req.reply(file);
      }).as("githubGetOrgInstallations");
    });
    cy.fixture("get-search.json").then((file) => {
      cy.intercept("GET", `https://api.github.com/search/repositories**`, (req) => {
        req.reply(file);
      }).as("githubSearch");
    });
    cy.fixture("put-config.json").then((file) => {
      cy.intercept("PUT", `https://api.github.com/repos/${ORG_NAME.toLowerCase()}/ubiquibot-config/contents/.github**`, (req) => {
        req.reply(file);
      }).as("githubPutContents");
    });
    cy.fixture("user-token.json").then((content) => {
      loginToken = content;
    });
  });

  it("Console is cleared of errors and warnings", () => {
    cy.visit("/", {
      onBeforeLoad(win) {
        cy.stub(win.console, "error").as("consoleError");
      },
    });
    cy.get("@consoleError").should("not.be.called");
    cy.get("body").should("exist");
  });

  it.only("Create onboarding repository", () => {
    cy.visit("/");
    cy.intercept("https://github.com/login/oauth/authorize**", (req) => {
      req.reply({
        statusCode: 200,
      });
      // Simulate login token
      // cspell:ignore wfzpewmlyiozupulbuur
      window.localStorage.setItem("sb-wfzpewmlyiozupulbuur-auth-token", JSON.stringify(loginToken));
    }).as("githubLogin");
    cy.get("#github-login-button").click();
    cy.visit("/");
    cy.wait("@githubGetUserOrgs");
    cy.get("#setBtn").click();
    cy.log("Display warning on empty WALLET_PRIVATE_KEY");
    cy.get(":nth-child(3) > .status-log.warn").contains(/.+/);
    cy.get("#orgName").select("ubiquity");
    cy.get("#setBtn").click();
    cy.get("#outKey").then((e) => {
      expect(e.val()).not.to.be.empty;
    });
    cy.log("Expected to be a step 2 of the form");
    cy.get("#stepper > :nth-child(2)").should("have.class", "active");
  });
});
