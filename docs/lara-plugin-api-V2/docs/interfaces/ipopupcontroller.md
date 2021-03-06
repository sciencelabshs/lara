[LARA Plugin API](../README.md) > [IPopupController](../interfaces/ipopupcontroller.md)

# Interface: IPopupController

## Hierarchy

**IPopupController**

## Index

### Properties

* [close](ipopupcontroller.md#close)
* [open](ipopupcontroller.md#open)
* [remove](ipopupcontroller.md#remove)

---

## Properties

<a id="close"></a>

###  close

**● close**: *`function`*

*Defined in [api/popup.ts:43](https://github.com/concord-consortium/lara/blob/5741bf58/lara-plugin-api-V2/src/api/popup.ts#L43)*

Closes popup (display: none). Also removes HTML element from DOM tree if `removeOnClose` is equal to true.

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="open"></a>

###  open

**● open**: *`function`*

*Defined in [api/popup.ts:41](https://github.com/concord-consortium/lara/blob/5741bf58/lara-plugin-api-V2/src/api/popup.ts#L41)*

Opens popup (makes sense only if autoOpen option is set to false during initialization).

#### Type declaration
▸(): `void`

**Returns:** `void`

___
<a id="remove"></a>

###  remove

**● remove**: *`function`*

*Defined in [api/popup.ts:45](https://github.com/concord-consortium/lara/blob/5741bf58/lara-plugin-api-V2/src/api/popup.ts#L45)*

Removes HTML element from DOM tree.

#### Type declaration
▸(): `void`

**Returns:** `void`

___

