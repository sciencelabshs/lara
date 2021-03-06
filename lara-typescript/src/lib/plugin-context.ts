import {
  IPluginRuntimeContext, IJwtResponse, IClassInfo, ILogData, IPluginAuthoringContext
} from "../plugin-api";
import { generateEmbeddableRuntimeContext } from "./embeddable-runtime-context";
import * as $ from "jquery";

export type IPluginContextOptions = IPluginRuntimeContextOptions | IPluginAuthoringContextOptions;

interface IPluginCommonOptions {
  /** Name of the plugin */
  name: string;
  /** Url from which the plugin was loaded. */
  url: string;
  /** Plugin instance ID. */
  pluginId: number;
  /** The authored configuration for this instance (if available). */
  authoredState: string | null;
  /** HTMLElement created by LARA for the plugin to use to render both its runtime and authoring output. */
  container: HTMLElement;
  /** Name of plugin component */
  componentLabel: string;
  /** Wrapped embeddable runtime context if plugin is wrapping some embeddable and the plugin has the
   * guiPreview option set to true within its manifest.
   */
  wrappedEmbeddable: IEmbeddableContextOptions | null;
  /** URL to fetch a JWT. Includes generic `_FIREBASE_APP_` that should be replaced with app name. */
  firebaseJwtUrl: string;
}

/** Data generated by LARA, passed to .initPlugin function, and then used to generate final IPluginRuntimeContext */
export interface IPluginRuntimeContextOptions extends IPluginCommonOptions {
  /** Type of the plugin */
  type: "runtime";
  /** The saved learner data for this instance (if available). */
  learnerState: string | null;
  /** URL used to save plugin state. */
  learnerStateSaveUrl: string;
  /** The run ID for the current LARA run. */
  runId: number;
  /** The portal remote endpoint (if available). */
  remoteEndpoint: string | null;
  /** The current users email address (if available). */
  userEmail: string | null;
  /** The portal URL for class details (if available). */
  classInfoUrl: string | null;
  /** The ID of the Embeddable that has been added to page, this embeddable refers to the plugin instance */
  embeddablePluginId: number | null;
  /** URL of the resource associated with the current run (sequence URL or activity URL) */
  resourceUrl: string;
}

export interface IPluginAuthoringContextOptions extends IPluginCommonOptions {
  /** Type of the plugin */
  type: "authoring";
  /** URL used to save plugin authoring state. */
  authorDataSaveUrl: string;
}

/** Data generated by LARA, passed to .initPlugin function, and then used to generate final IEmbeddableRuntimeContext */
export interface IEmbeddableContextOptions {
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

const ajaxPromise = (url: string, data: object): Promise<string> => {
  return new Promise((resolve, reject) => {
    $.ajax({
      url,
      type: "PUT",
      data,
      success(result) {
        resolve(result);
      },
      error(jqXHR, errText, err) {
        reject(err);
      }
    });
  });
};

export const saveLearnerPluginState = (learnerStateSaveUrl: string, state: string): Promise<string> => {
  return ajaxPromise(learnerStateSaveUrl, { state });
};

export const saveAuthoredPluginState = (authoringSaveStateUrl: string, authorData: string): Promise<string> => {
  return ajaxPromise(authoringSaveStateUrl, { author_data: authorData });
};

const getFirebaseJwt = (firebaseJwtUrl: string, appName: string): Promise<IJwtResponse> => {
  const appSpecificUrl = firebaseJwtUrl.replace("_FIREBASE_APP_", appName);
  return fetch(appSpecificUrl, {method: "POST"})
    .then(response => response.json())
    .then(data => {
      if (data.response_type === "ERROR") {
        throw {message: data.message};
      }
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

const log = (context: IPluginRuntimeContextOptions, logData: string | ILogData): void => {
  const logger = (window as any).loggerUtils;
  if (logger) {
    if (typeof(logData) === "string") {
      logData = {event: logData};
    }
    const pluginLogData = Object.assign(fetchPluginEventLogData(context), logData);
    logger.log(pluginLogData);
  }
};

const fetchPluginEventLogData = (context: IPluginRuntimeContextOptions) => {
  const logData: any = {
    plugin_id: context.pluginId
  };
  if (context.embeddablePluginId) {
    logData.embeddable_plugin_id = context.embeddablePluginId;
  }
  if (context.wrappedEmbeddable) {
    logData.wrapped_embeddable_type = context.wrappedEmbeddable.laraJson.type;
    logData.wrapped_embeddable_id = context.wrappedEmbeddable.laraJson.ref_id;
  }
  return logData;
};

export const generateRuntimePluginContext = (options: IPluginRuntimeContextOptions): IPluginRuntimeContext => {
  const context = {
    name: options.name,
    url: options.url,
    pluginId: options.pluginId,
    authoredState: options.authoredState,
    learnerState: options.learnerState,
    container: options.container,
    runId: options.runId,
    remoteEndpoint: options.remoteEndpoint,
    userEmail: options.userEmail,
    resourceUrl: options.resourceUrl,
    saveLearnerPluginState: (state: string) => saveLearnerPluginState(options.learnerStateSaveUrl, state),
    getClassInfo: () => getClassInfo(options.classInfoUrl),
    getFirebaseJwt: (appName: string) => getFirebaseJwt(options.firebaseJwtUrl, appName),
    wrappedEmbeddable: options.wrappedEmbeddable ? generateEmbeddableRuntimeContext(options.wrappedEmbeddable) : null,
    log: (logData: string | ILogData) => log(options, logData)
  };
  return context;
};

export const generateAuthoringPluginContext = (options: IPluginAuthoringContextOptions): IPluginAuthoringContext => {
  return {
    name: options.name,
    url: options.url,
    pluginId: options.pluginId,
    authoredState: options.authoredState,
    container: options.container,
    componentLabel: options.componentLabel,
    saveAuthoredPluginState: (state: string) => saveAuthoredPluginState(options.authorDataSaveUrl, state),
    wrappedEmbeddable: options.wrappedEmbeddable ? generateEmbeddableRuntimeContext(options.wrappedEmbeddable) : null,
    getFirebaseJwt: (appName: string) => getFirebaseJwt(options.firebaseJwtUrl, appName)
  };
};
