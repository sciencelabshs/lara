(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("jQuery"), require("jQuery.ui"), require("Sidebar"), require("TextDecorator"));
	else if(typeof define === 'function' && define.amd)
		define(["jQuery", "jQuery.ui", "Sidebar", "TextDecorator"], factory);
	else if(typeof exports === 'object')
		exports["LARA"] = factory(require("jQuery"), require("jQuery.ui"), require("Sidebar"), require("TextDecorator"));
	else
		root["LARA"] = factory(root["jQuery"], root["jQuery.ui"], root["Sidebar"], root["TextDecorator"]);
})(window, function(__WEBPACK_EXTERNAL_MODULE_jquery__, __WEBPACK_EXTERNAL_MODULE_jqueryui__, __WEBPACK_EXTERNAL_MODULE_sidebar__, __WEBPACK_EXTERNAL_MODULE_text_decorator__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/lara-plugin-api.ts");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./src/api/plugins.ts":
/*!****************************!*\
  !*** ./src/api/plugins.ts ***!
  \****************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
/****************************************************************************
 Module variables to keep track of our plugins.
 Note, we call these `classes` but any constructor function will do.
 ****************************************************************************/
var pluginClasses = {};
var plugins = [];
var pluginLabels = [];
var pluginStatePaths = {};
var pluginError = function (e, other) {
    // tslint:disable-next-line:no-console
    console.group("LARA Plugin Error");
    // tslint:disable-next-line:no-console
    console.error(e);
    // tslint:disable-next-line:no-console
    console.dir(other);
    // tslint:disable-next-line:no-console
    console.groupEnd();
};
/****************************************************************************
 Note that this method is NOT meant to be called by plugins. It's used by LARA internals.
 This method is called to initialize the plugin.
 Called at runtime by LARA to create an instance of the plugin as would happen in `views/plugin/_show.html.haml`.
 @param label The the script identifier.
 @param runtimeContext Context for the plugin.
 @param pluginStatePath For saving & loading learner data.
 ****************************************************************************/
exports.initPlugin = function (label, runtimeContext, pluginStatePath) {
    var constructor = pluginClasses[label];
    var plugin = null;
    if (typeof constructor === "function") {
        try {
            plugin = new constructor(runtimeContext);
            plugins.push(plugin);
            pluginLabels.push(label);
            pluginStatePaths[runtimeContext.pluginId] = pluginStatePath;
        }
        catch (e) {
            pluginError(e, runtimeContext);
        }
        // tslint:disable-next-line:no-console
        console.info("Plugin", label, "is now registered");
    }
    else {
        // tslint:disable-next-line:no-console
        console.error("No plugin registered for label:", label);
    }
};
/****************************************************************************
 Ask LARA to save the users state for the plugin.
 ```
 LARA.saveLearnerPluginState(pluginId, '{"one": 1}').then((data) => console.log(data))
 ```
 @param pluginId ID of the plugin trying to save data, initially passed to plugin constructor in the context.
 @param state A JSON string representing serialized plugin state.
 ****************************************************************************/
exports.saveLearnerPluginState = function (pluginId, state) {
    var paths = pluginStatePaths[pluginId];
    if (paths && paths.savePath) {
        return new Promise(function (resolve, reject) {
            $.ajax({
                url: paths.savePath,
                type: "PUT",
                data: { state: state },
                success: function (data) {
                    resolve(data);
                },
                error: function (jqXHR, errText, err) {
                    reject(err);
                }
            });
        });
    }
    var msg = "Not saved.`pluginStatePaths` missing for plugin ID:";
    // tslint:disable-next-line:no-console
    console.warn(msg, pluginId);
    return Promise.reject(msg);
};
/****************************************************************************
 Register a new external script as `label` with `_class `, e.g.:
 ```
 registerPlugin('debugger', Dubugger)
 ```
 @param label The identifier of the script.
 @param _class The Plugin class/constructor being associated with the identifier.
 @returns `true` if plugin was registered correctly.
 ***************************************************************************/
exports.registerPlugin = function (label, _class) {
    if (typeof _class !== "function") {
        // tslint:disable-next-line:no-console
        console.error("Plugin did not provide constructor", label);
        return false;
    }
    if (pluginClasses[label]) {
        // tslint:disable-next-line:no-console
        console.error("Duplicate Plugin for label", label);
        return false;
    }
    else {
        pluginClasses[label] = _class;
        return true;
    }
};


/***/ }),

/***/ "./src/lara-plugin-api.ts":
/*!********************************!*\
  !*** ./src/lara-plugin-api.ts ***!
  \********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var $ = __webpack_require__(/*! jquery */ "jquery");
__webpack_require__(/*! jqueryui */ "jqueryui");
var Sidebar = __webpack_require__(/*! sidebar */ "sidebar");
var TextDecorator = __webpack_require__(/*! text-decorator */ "text-decorator");
var plugins_1 = __webpack_require__(/*! ./api/plugins */ "./src/api/plugins.ts");
exports.registerPlugin = plugins_1.registerPlugin;
exports.initPlugin = plugins_1.initPlugin;
exports.saveLearnerPluginState = plugins_1.saveLearnerPluginState;
var ADD_POPUP_DEFAULT_OPTIONS = {
    title: "",
    autoOpen: true,
    closeButton: true,
    closeOnEscape: false,
    removeOnClose: true,
    modal: false,
    draggable: true,
    resizable: true,
    width: 300,
    height: "auto",
    padding: 10,
    /**
     * Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
     * current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.
     */
    dialogClass: "",
    backgroundColor: "",
    titlebarColor: "",
    position: { my: "center", at: "center", of: window },
    onOpen: null,
    onBeforeClose: null,
    onResize: null,
    onDragStart: null,
    onDragStop: null
};
/****************************************************************************
 Ask LARA to add a new popup window.

 Note that many options closely resemble jQuery UI dialog options which is used under the hood.
 You can refer to jQuery UI API docs in many cases: https://api.jqueryui.com/dialog
 Only `content` is required. Other options have reasonable default values (subject to change,
 so if you expect particular behaviour, provide necessary options explicitly).

 React warning: if you use React to render content, remember to call `ReactDOM.unmountComponentAtNode(content)`
 in `onRemove` handler.
 ****************************************************************************/
exports.addPopup = function (_options) {
    var options = $.extend({}, ADD_POPUP_DEFAULT_OPTIONS, _options);
    if (!options.content) {
        throw new Error("LARA.addPopup - content option is required");
    }
    if (options.dialogClass) {
        // tslint:disable-next-line:no-console
        console.warn("LARA.addPopup - dialogClass option is discouraged and should not be used by plugins");
    }
    var $content = typeof options.content === "string" ?
        $("<span>" + options.content + "</span>") : $(options.content);
    var $dialog;
    var remove = function () {
        if (options.onRemove) {
            options.onRemove();
        }
        $dialog.remove();
    };
    $content.dialog({
        title: options.title,
        autoOpen: options.autoOpen,
        closeOnEscape: options.closeOnEscape,
        modal: options.modal,
        draggable: options.draggable,
        width: options.width,
        height: options.height,
        resizable: options.resizable,
        // Note that dialogClass is intentionally undocumented. Styling uses class makes us depend on the
        // current dialog implementation. It might be necessary for LARA themes, although plugins should not use it.
        dialogClass: options.dialogClass,
        position: options.position,
        open: options.onOpen,
        close: function () {
            if (options.onClose) {
                options.onClose();
            }
            // Remove dialog from DOM tree.
            if (options.removeOnClose) {
                remove();
            }
        },
        beforeClose: options.onBeforeClose,
        resize: options.onResize,
        dragStart: options.onDragStart,
        dragStop: options.onDragStop
    });
    $dialog = $content.closest(".ui-dialog");
    $dialog.css("background", options.backgroundColor);
    $dialog.find(".ui-dialog-titlebar").css("background", options.titlebarColor);
    $dialog.find(".ui-dialog-content").css("padding", options.padding);
    if (!options.closeButton) {
        $dialog.find(".ui-dialog-titlebar-close").remove();
    }
    // IPopupController implementation.
    return {
        open: function () {
            $content.dialog("open");
        },
        close: function () {
            $content.dialog("close");
        },
        remove: remove
    };
};
var ADD_SIDEBAR_DEFAULT_OPTIONS = {
    icon: "default",
    handle: "",
    handleColor: "#aaa",
    titleBar: null,
    titleBarColor: "#bbb",
    width: 500,
    padding: 25,
    onOpen: null,
    onClose: null
};
/****************************************************************************
 Ask LARA to add a new sidebar.

 Sidebar will be added to the edge of the interactive page window. When multiple sidebars are added, there's no way
 to specify their positions, so no assumptions should be made about current display - it might change.

 Sidebar height cannot be specified. It's done on purpose to prevent issues on very short screens. It's based on the
 provided content HTML element, but it's limited to following range:
 - 100px is the min-height
 - max-height is calculated dynamically and ensures that sidebar won't go off the screen
 If the provided content is taller than the max-height of the sidebar, a sidebar content container will scroll.

 It returns a simple controller that can be used to open or close sidebar.
 ****************************************************************************/
exports.addSidebar = function (options) {
    options = $.extend({}, ADD_SIDEBAR_DEFAULT_OPTIONS, options);
    if (options.icon === "default") {
        options.icon = $("<i class='default-icon fa fa-arrow-circle-left'>")[0];
    }
    return Sidebar.addSidebar(options);
};
/****************************************************************************
 Ask LARA to decorate authored content (text / html).

 @param words A list of case-insensitive words to be decorated. Can use limited regex.
 @param replace The replacement string. Can include '$1' representing the matched word.
 @param wordClass CSS class used in replacement string. Necessary only if `listeners` are provided too.
 @param listeners One or more { type, listener } tuples. Note that events are added to `wordClass`
 described above. It's client code responsibility to use this class in the `replace` string.
 ****************************************************************************/
exports.decorateContent = function (words, replace, wordClass, listeners) {
    var domClasses = ["question-txt", "help-content", "intro-txt"];
    var options = {
        words: words,
        replace: replace
    };
    TextDecorator.decorateDOMClasses(domClasses, options, wordClass, listeners);
};
/**************************************************************
 Find out if the page being displayed is being run in teacher-edition
 @returns `true` if lara is running in teacher-edition.
 **************************************************************/
exports.isTeacherEdition = function () {
    // If we decide to do something more complex in the future,
    // the client's API won't change.
    return window.location.search.indexOf("mode=teacher-edition") > 0;
};


/***/ }),

/***/ "jquery":
/*!*************************!*\
  !*** external "jQuery" ***!
  \*************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_jquery__;

/***/ }),

/***/ "jqueryui":
/*!****************************!*\
  !*** external "jQuery.ui" ***!
  \****************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_jqueryui__;

/***/ }),

/***/ "sidebar":
/*!**************************!*\
  !*** external "Sidebar" ***!
  \**************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_sidebar__;

/***/ }),

/***/ "text-decorator":
/*!********************************!*\
  !*** external "TextDecorator" ***!
  \********************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = __WEBPACK_EXTERNAL_MODULE_text_decorator__;

/***/ })

/******/ });
});