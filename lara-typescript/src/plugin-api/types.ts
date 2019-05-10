export interface IPlugin {
  /** No special requirements for plugin class */
}

export type IPluginConstructor = new(runtimeContext: IPluginRuntimeContext) => IPlugin;

export interface IPluginRuntimeContext {
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
  /** Reserved HTMLElement for the plugin output. */
  container: HTMLElement;
  /** The run ID for the current LARA run. */
  runId: number;
  /** The portal remote endpoint (if available). */
  remoteEndpoint: string | null;
  /** The current user email address (if available). */
  userEmail: string | null;
  /****************************************************************************
   Function that saves the users state for the plugin.
   Note that plugins can have different scopes, e.g. activity or a single page.
   If the plugin instance is added to the activity, its state will be shared across all the pages.
   If multiple plugin instances are added to various pages, their state will be different on every page.
   ```
   context.saveLearnerPluginState('{"one": 1}').then((data) => console.log(data))
   ```
   @param state A string representing serialized plugin state; if it's JSON, remember to stringify it first.
   ****************************************************************************/
  saveLearnerPluginState: (state: string) => Promise<string>;
  /** Function that returns class details (Promise) or null if class info is not available. */
  getClassInfo: () => Promise<IClassInfo> | null;
  /** Function that returns JWT (Promise) for given app name. */
  getFirebaseJwt: (appName: string) => Promise<IJwtResponse>;
  /** Wrapped embeddable runtime context if plugin is wrapping some embeddable. */
  wrappedEmbeddable: IEmbeddableRuntimeContext | null;
}

export interface IEmbeddableRuntimeContext {
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
  /** Function that returns interactive state (Promise) or null if embeddable isn't interactive. */
  getInteractiveState: () => Promise<IInteractiveState> | null;
  /****************************************************************************
   Function that returns reporting URL (Promise) or null if it's not an interactive or reporting URL is not defined.
   Note that reporting URL is defined in the interactive state (that can be obtained via #getInteractiveState method).
   If your code needs both interactive state and reporting URL, you can pass interactiveStatePromise as an argument
   to this method to limit number of network requests.

   @param interactiveStatePromise? An optional promise returned from #getInteractiveState method. If it's provided
          this function will use it to get interacive state and won't issue any additional network requests.
   ****************************************************************************/
  getReportingUrl: (interactiveStatePromise?: Promise<IInteractiveState>) => Promise<string | null> | null;
  /****************************************************************************
   Function that subscribes provided handler to event that gets called when the interactive with click to play mode
   is started by the user. Note that it will work only if given embeddable is an interactive and it has click to play
   mode enabled by author.

   @param handler Event handler function.
   ****************************************************************************/
  onClickToPlayStarted: (handler: IClickToPlayStartedEventHandler) => void;
}

export interface IPortalClaims {
  user_type: "learner" | "teacher";
  user_id: string;
  class_hash: string;
  offering_id: number;
}

export interface IJwtClaims {
  domain: string;
  returnUrl: string;
  externalId: number;
  class_info_url: string;
  claims: IPortalClaims;
}

export interface IJwtResponse {
  token: string;
  claims: IJwtClaims | {};
}

export interface IUser {
  id: string; // path
  first_name: string;
  last_name: string;
}

export interface IOffering {
  id: number;
  name: string;
  url: string;
}

export interface IClassInfo {
  id: number;
  uri: string;
  class_hash: string;
  teachers: IUser[];
  students: IUser[];
  offerings: IOffering[];
}

export interface IInteractiveState {
  id: number;
  key: string;
  raw_data: string;
  interactive_name: string;
  interactive_state_url: string;
  activity_name: string;
}

/**
 * That's the minimal set of properties that needs to be provided.
 * All the other properties provides go to the `extra` hash.
 */
export interface ILogData {
  event: string;
  event_value?: any;
  parameters?: any;
}

/**
 * Log event handler.
 * @param logData Data logged by the code.
 */
export type ILogEventHandler = (event: ILogData) => void;

/**
 * Data passed to ClickToPlayStarted event handlers.
 */
export interface IClickToPlayStartedEvent {
  /**
   * Interactive container of the interactive that was just started.
   */
  container: HTMLElement;
}

/**
 * ClickToPlayStarted event handler.
 */
export type IClickToPlayStartedEventHandler = (event: IClickToPlayStartedEvent) => void;