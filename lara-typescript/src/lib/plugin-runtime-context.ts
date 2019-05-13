import {
  IPluginRuntimeContext, IJwtResponse, IClassInfo
} from "../plugin-api";
import { generateEmbeddableRuntimeContext } from "./embeddable-runtime-context";
import * as $ from "jquery";

/** Data generated by LARA, passed to .initPlugin function, and then used to generate final IPluginRuntimeContext */
export interface IPluginContext {
  /** Name of the plugin */
  name: string;
  /** Url from which the plugin was loaded. */
  url: string;
  /** Plugin instance ID. */
  pluginId: number;
  /** The authored configuration for this instance (if available). */
  authoredState: string | null;
  /** The saved learner data for this instance (if available). */
  learnerState: string | null;
  /** URL used to save plugin state. */
  learnerStateSaveUrl: string;
  /** Reserved HTMLElement for the plugin output. */
  container: HTMLElement;
  /** The run ID for the current LARA run. */
  runId: number;
  /** The portal remote endpoint (if available). */
  remoteEndpoint: string | null;
  /** The current users email address (if available). */
  userEmail: string | null;
  /** The portal URL for class details (if available). */
  classInfoUrl: string | null;
  /** URL to fetch a JWT. Includes generic `_FIREBASE_APP_` that should be replaced with app name. */
  firebaseJwtUrl: string;
  /** Wrapped embeddable runtime context if plugin is wrapping some embeddable. */
  wrappedEmbeddable: IEmbeddableContext | null;
}

/** Data generated by LARA, passed to .initPlugin function, and then used to generate final IEmbeddableRuntimeContext */
export interface IEmbeddableContext {
  /** Embeddable container. */
  container: HTMLElement;
  /****************************************************************************
   Serialized form of the embeddable. Defined by LARA export code, so it's format cannot be specified here.
   Example (interactive):
   ```
   {
     aspect_ratio_method: "DEFAULT",
     authored_state: null,
     click_to_play: false,
     enable_learner_state: true,
     name: "Test Interactive",
     native_height: 435,
     native_width: 576,
     url: "http://concord-consortium.github.io/lara-interactive-api/iframe.html",
     type: "MwInteractive",
     ref_id: "86-MwInteractive"
   }
   ```
   ****************************************************************************/
  laraJson: any;
  /** Interactive state URL, available only when plugin is wrapping an interactive. */
  interactiveStateUrl: string | null;
  /** True if the interactive is immediately available for use */
  interactiveAvailable: boolean;
}

export const saveLearnerPluginState = (learnerStateSaveUrl: string, state: string): Promise<string> => {
  return new Promise((resolve, reject) => {
    $.ajax({
      url: learnerStateSaveUrl,
      type: "PUT",
      data: { state },
      success(data) {
        resolve(data);
      },
      error(jqXHR, errText, err) {
        reject(err);
      }
    });
  });
};

const getFirebaseJwt = (firebaseJwtUrl: string, appName: string): Promise<IJwtResponse> => {
  const appSpecificUrl = firebaseJwtUrl.replace("_FIREBASE_APP_", appName);
  return fetch(appSpecificUrl, {method: "POST"})
    .then(response => response.json())
    .then(data => {
      try {
        const token = data.token.split(".")[1];
        const claimsJson = atob(token);
        const claims = JSON.parse(claimsJson);
        return {token: data.token, claims};
      } catch (error) {
        throw { message: "Unable to parse JWT Token", error };
      }
    });
};

const getClassInfo = (classInfoUrl: string | null): Promise<IClassInfo> | null => {
  if (!classInfoUrl) {
    return null;
  }
  return fetch(classInfoUrl, {method: "get", credentials: "include"}).then(resp => resp.json());
};

export const generatePluginRuntimeContext = (context: IPluginContext): IPluginRuntimeContext => {
  return {
    name: context.name,
    url: context.url,
    pluginId: context.pluginId,
    authoredState: context.authoredState,
    learnerState: context.learnerState,
    container: context.container,
    runId: context.runId,
    remoteEndpoint: context.remoteEndpoint,
    userEmail: context.userEmail,
    saveLearnerPluginState: (state: string) => saveLearnerPluginState(context.learnerStateSaveUrl, state),
    getClassInfo: () => getClassInfo(context.classInfoUrl),
    getFirebaseJwt: (appName: string) => getFirebaseJwt(context.firebaseJwtUrl, appName),
    wrappedEmbeddable: context.wrappedEmbeddable ? generateEmbeddableRuntimeContext(context.wrappedEmbeddable) : null
  };
};
