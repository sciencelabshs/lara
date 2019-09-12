// Wrapper around cy.request() method that automatically grabs and sets LARA CSRF token.
Cypress.Commands.add("requestWithToken", (options) => {
  return cy.get('meta[name="csrf-token"]').then(token => {
    const newOptions = Object.assign({}, options)
    if (!newOptions.headers) {
      newOptions.headers = {}
    }
    newOptions.headers['X-CSRF-Token'] = token.attr('content');
    return cy.request(newOptions)
  })
})

// By default it uses credentials specified in config/user-config.json
Cypress.Commands.add("login", (username = Cypress.config("username"), password = Cypress.config("password")) => {
  cy.visit('/users/sign_in')
  cy.get('#user_email').type(username)
  cy.get('#user_password').type(password)
  cy.get('input[name="commit"]').click()
})

// By default it uses credentials specified in config/user-config.json
Cypress.Commands.add("logout", () => {
  cy.requestWithToken({
    url: "/users/sign_out",
    method: "DELETE"
  })
})

Cypress.Commands.add("importMaterial", fixturePath => {
  return cy.fixture(fixturePath).then(materialJSON => {
    const name = materialJSON.name || materialJSON.title
    expect(name, "Wrong material name - no [Cypress] prefix").to.match(/^\[Cypress]/)
    return cy.requestWithToken({
      url: `${Cypress.config("baseUrl")}/api/v1/import`,
      method: "POST",
      body: {"import": materialJSON}
    }).then(response => {
      const body = response.body
      if (!body.success) {
        throw Error("Import has failed " + response.body.error)
      }
      return body.url
    })
  })
})

Cypress.Commands.add("deleteMaterial", materialUrl => {
  let type
  if (materialUrl.indexOf("/activities/") !== -1) {
    type = "activities"
  } else {
    type = "sequences"
  }
  // E.g. "https://authoring.concord.org/activities/123 => ["https://authoring.concord.org", "123"]
  const [ baseUrl, id ] = materialUrl.split(`/${type}/`)
  // This visit does not seem to be necessary. However, it seems that on some pages CSRF token can't be found.
  // Do it for safety, as we don't want to leave test materials around.
  cy.visit("/")
  return cy.requestWithToken({
    url: `${baseUrl}/api/v1/${type}/${id}`,
    method: "DELETE",
  })
})

// The first page has index 0!
Cypress.Commands.add("visitActivityPage", (activityUrl, page) => {
  cy.visit(activityUrl)
  cy.get(".page-index li").eq(page).find("a").click()
})

// Used for iFrame Interactives
Cypress.Commands.add("getIframe", () => {
  return cy.get(".interactive-container iframe").iframe()
});

Cypress.Commands.add("iframe", { prevSubject: "element" }, $iframe => {
    cy.get('iframe').then(function ($iframe) {
        const $jbody = $iframe.contents().find('body');
        const $body = $jbody[0];
        return $body;
    })
});

// Cypress.Commands.add("iframe", { prevSubject: "element" }, $iframe => {
//   Cypress.log({
//       name: "iframe",
//       consoleProps() {
//           return {
//               iframe: $iframe,
//           };
//       },
//   });
//   return new Cypress.Promise(resolve => {
//       onIframeReady(
//           $iframe,
//           () => {
//               resolve($iframe.contents().find("body"));
//           },
//           () => {
//               $iframe.on("load", () => {
//                   resolve($iframe.contents().find("body"));
//               });
//           }
//       );
//   });
// });

// function onIframeReady($iframe, successFn, errorFn) {
//   try {
//       const iCon = $iframe.first()[0].contentWindow,
//           bl = "about:blank",
//           compl = "complete";
//       const callCallback = () => {
//           try {
//               const $con = $iframe.contents();
//               if ($con.length === 0) {
//                   // https://git.io/vV8yU
//                   throw new Error("iframe inaccessible");
//               }
//               successFn($con);
//           } catch (e) {
//               // accessing contents failed
//               errorFn();
//           }
//       };
//       const observeOnload = () => {
//           $iframe.on("load.jqueryMark", () => {
//               try {
//                   const src = $iframe.attr("src").trim(),
//                       href = iCon.location.href;
//                   if (href !== bl || src === bl || src === "") {
//                       $iframe.off("load.jqueryMark");
//                       callCallback();
//                   }
//               } catch (e) {
//                   errorFn();
//               }
//           });
//       };
//       if (iCon.document.readyState === compl) {
//           const src = $iframe.attr("src").trim(),
//               href = iCon.location.href;
//           if (href === bl && src !== bl && src !== "") {
//               observeOnload();
//           } else {
//               callCallback();
//           }
//       } else {
//           observeOnload();
//       }
//   } catch (e) {
//       // accessing contentWindow failed
//       errorFn();
//   }
// }

