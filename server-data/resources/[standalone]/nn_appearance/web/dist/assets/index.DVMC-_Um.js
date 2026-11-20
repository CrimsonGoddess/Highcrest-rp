(function(){const t=document.createElement("link").relList;if(t&&t.supports&&t.supports("modulepreload"))return;for(const o of document.querySelectorAll('link[rel="modulepreload"]'))r(o);new MutationObserver(o=>{for(const i of o)if(i.type==="childList")for(const l of i.addedNodes)l.tagName==="LINK"&&l.rel==="modulepreload"&&r(l)}).observe(document,{childList:!0,subtree:!0});function n(o){const i={};return o.integrity&&(i.integrity=o.integrity),o.referrerPolicy&&(i.referrerPolicy=o.referrerPolicy),o.crossOrigin==="use-credentials"?i.credentials="include":o.crossOrigin==="anonymous"?i.credentials="omit":i.credentials="same-origin",i}function r(o){if(o.ep)return;o.ep=!0;const i=n(o);fetch(o.href,i)}})();function t0(e){return e&&e.__esModule&&Object.prototype.hasOwnProperty.call(e,"default")?e.default:e}var Kc={exports:{}},zi={},Yc={exports:{}},A={};/**
 * @license React
 * react.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */var fo=Symbol.for("react.element"),n0=Symbol.for("react.portal"),r0=Symbol.for("react.fragment"),o0=Symbol.for("react.strict_mode"),i0=Symbol.for("react.profiler"),l0=Symbol.for("react.provider"),a0=Symbol.for("react.context"),s0=Symbol.for("react.forward_ref"),u0=Symbol.for("react.suspense"),c0=Symbol.for("react.memo"),d0=Symbol.for("react.lazy"),iu=Symbol.iterator;function f0(e){return e===null||typeof e!="object"?null:(e=iu&&e[iu]||e["@@iterator"],typeof e=="function"?e:null)}var Qc={isMounted:function(){return!1},enqueueForceUpdate:function(){},enqueueReplaceState:function(){},enqueueSetState:function(){}},Zc=Object.assign,Xc={};function ur(e,t,n){this.props=e,this.context=t,this.refs=Xc,this.updater=n||Qc}ur.prototype.isReactComponent={};ur.prototype.setState=function(e,t){if(typeof e!="object"&&typeof e!="function"&&e!=null)throw Error("setState(...): takes an object of state variables to update or a function which returns an object of state variables.");this.updater.enqueueSetState(this,e,t,"setState")};ur.prototype.forceUpdate=function(e){this.updater.enqueueForceUpdate(this,e,"forceUpdate")};function Jc(){}Jc.prototype=ur.prototype;function Ya(e,t,n){this.props=e,this.context=t,this.refs=Xc,this.updater=n||Qc}var Qa=Ya.prototype=new Jc;Qa.constructor=Ya;Zc(Qa,ur.prototype);Qa.isPureReactComponent=!0;var lu=Array.isArray,qc=Object.prototype.hasOwnProperty,Za={current:null},ed={key:!0,ref:!0,__self:!0,__source:!0};function td(e,t,n){var r,o={},i=null,l=null;if(t!=null)for(r in t.ref!==void 0&&(l=t.ref),t.key!==void 0&&(i=""+t.key),t)qc.call(t,r)&&!ed.hasOwnProperty(r)&&(o[r]=t[r]);var a=arguments.length-2;if(a===1)o.children=n;else if(1<a){for(var s=Array(a),c=0;c<a;c++)s[c]=arguments[c+2];o.children=s}if(e&&e.defaultProps)for(r in a=e.defaultProps,a)o[r]===void 0&&(o[r]=a[r]);return{$$typeof:fo,type:e,key:i,ref:l,props:o,_owner:Za.current}}function p0(e,t){return{$$typeof:fo,type:e.type,key:t,ref:e.ref,props:e.props,_owner:e._owner}}function Xa(e){return typeof e=="object"&&e!==null&&e.$$typeof===fo}function h0(e){var t={"=":"=0",":":"=2"};return"$"+e.replace(/[=:]/g,function(n){return t[n]})}var au=/\/+/g;function al(e,t){return typeof e=="object"&&e!==null&&e.key!=null?h0(""+e.key):t.toString(36)}function Uo(e,t,n,r,o){var i=typeof e;(i==="undefined"||i==="boolean")&&(e=null);var l=!1;if(e===null)l=!0;else switch(i){case"string":case"number":l=!0;break;case"object":switch(e.$$typeof){case fo:case n0:l=!0}}if(l)return l=e,o=o(l),e=r===""?"."+al(l,0):r,lu(o)?(n="",e!=null&&(n=e.replace(au,"$&/")+"/"),Uo(o,t,n,"",function(c){return c})):o!=null&&(Xa(o)&&(o=p0(o,n+(!o.key||l&&l.key===o.key?"":(""+o.key).replace(au,"$&/")+"/")+e)),t.push(o)),1;if(l=0,r=r===""?".":r+":",lu(e))for(var a=0;a<e.length;a++){i=e[a];var s=r+al(i,a);l+=Uo(i,t,n,s,o)}else if(s=f0(e),typeof s=="function")for(e=s.call(e),a=0;!(i=e.next()).done;)i=i.value,s=r+al(i,a++),l+=Uo(i,t,n,s,o);else if(i==="object")throw t=String(e),Error("Objects are not valid as a React child (found: "+(t==="[object Object]"?"object with keys {"+Object.keys(e).join(", ")+"}":t)+"). If you meant to render a collection of children, use an array instead.");return l}function Co(e,t,n){if(e==null)return e;var r=[],o=0;return Uo(e,r,"","",function(i){return t.call(n,i,o++)}),r}function m0(e){if(e._status===-1){var t=e._result;t=t(),t.then(function(n){(e._status===0||e._status===-1)&&(e._status=1,e._result=n)},function(n){(e._status===0||e._status===-1)&&(e._status=2,e._result=n)}),e._status===-1&&(e._status=0,e._result=t)}if(e._status===1)return e._result.default;throw e._result}var Le={current:null},Wo={transition:null},g0={ReactCurrentDispatcher:Le,ReactCurrentBatchConfig:Wo,ReactCurrentOwner:Za};function nd(){throw Error("act(...) is not supported in production builds of React.")}A.Children={map:Co,forEach:function(e,t,n){Co(e,function(){t.apply(this,arguments)},n)},count:function(e){var t=0;return Co(e,function(){t++}),t},toArray:function(e){return Co(e,function(t){return t})||[]},only:function(e){if(!Xa(e))throw Error("React.Children.only expected to receive a single React element child.");return e}};A.Component=ur;A.Fragment=r0;A.Profiler=i0;A.PureComponent=Ya;A.StrictMode=o0;A.Suspense=u0;A.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED=g0;A.act=nd;A.cloneElement=function(e,t,n){if(e==null)throw Error("React.cloneElement(...): The argument must be a React element, but you passed "+e+".");var r=Zc({},e.props),o=e.key,i=e.ref,l=e._owner;if(t!=null){if(t.ref!==void 0&&(i=t.ref,l=Za.current),t.key!==void 0&&(o=""+t.key),e.type&&e.type.defaultProps)var a=e.type.defaultProps;for(s in t)qc.call(t,s)&&!ed.hasOwnProperty(s)&&(r[s]=t[s]===void 0&&a!==void 0?a[s]:t[s])}var s=arguments.length-2;if(s===1)r.children=n;else if(1<s){a=Array(s);for(var c=0;c<s;c++)a[c]=arguments[c+2];r.children=a}return{$$typeof:fo,type:e.type,key:o,ref:i,props:r,_owner:l}};A.createContext=function(e){return e={$$typeof:a0,_currentValue:e,_currentValue2:e,_threadCount:0,Provider:null,Consumer:null,_defaultValue:null,_globalName:null},e.Provider={$$typeof:l0,_context:e},e.Consumer=e};A.createElement=td;A.createFactory=function(e){var t=td.bind(null,e);return t.type=e,t};A.createRef=function(){return{current:null}};A.forwardRef=function(e){return{$$typeof:s0,render:e}};A.isValidElement=Xa;A.lazy=function(e){return{$$typeof:d0,_payload:{_status:-1,_result:e},_init:m0}};A.memo=function(e,t){return{$$typeof:c0,type:e,compare:t===void 0?null:t}};A.startTransition=function(e){var t=Wo.transition;Wo.transition={};try{e()}finally{Wo.transition=t}};A.unstable_act=nd;A.useCallback=function(e,t){return Le.current.useCallback(e,t)};A.useContext=function(e){return Le.current.useContext(e)};A.useDebugValue=function(){};A.useDeferredValue=function(e){return Le.current.useDeferredValue(e)};A.useEffect=function(e,t){return Le.current.useEffect(e,t)};A.useId=function(){return Le.current.useId()};A.useImperativeHandle=function(e,t,n){return Le.current.useImperativeHandle(e,t,n)};A.useInsertionEffect=function(e,t){return Le.current.useInsertionEffect(e,t)};A.useLayoutEffect=function(e,t){return Le.current.useLayoutEffect(e,t)};A.useMemo=function(e,t){return Le.current.useMemo(e,t)};A.useReducer=function(e,t,n){return Le.current.useReducer(e,t,n)};A.useRef=function(e){return Le.current.useRef(e)};A.useState=function(e){return Le.current.useState(e)};A.useSyncExternalStore=function(e,t,n){return Le.current.useSyncExternalStore(e,t,n)};A.useTransition=function(){return Le.current.useTransition()};A.version="18.3.1";Yc.exports=A;var j=Yc.exports;const Fe=t0(j);/**
 * @license React
 * react-jsx-runtime.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */var y0=j,x0=Symbol.for("react.element"),v0=Symbol.for("react.fragment"),w0=Object.prototype.hasOwnProperty,k0=y0.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentOwner,S0={key:!0,ref:!0,__self:!0,__source:!0};function rd(e,t,n){var r,o={},i=null,l=null;n!==void 0&&(i=""+n),t.key!==void 0&&(i=""+t.key),t.ref!==void 0&&(l=t.ref);for(r in t)w0.call(t,r)&&!S0.hasOwnProperty(r)&&(o[r]=t[r]);if(e&&e.defaultProps)for(r in t=e.defaultProps,t)o[r]===void 0&&(o[r]=t[r]);return{$$typeof:x0,type:e,key:i,ref:l,props:o,_owner:k0.current}}zi.Fragment=v0;zi.jsx=rd;zi.jsxs=rd;Kc.exports=zi;var u=Kc.exports,Wl={},od={exports:{}},We={},id={exports:{}},ld={};/**
 * @license React
 * scheduler.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */(function(e){function t(T,P){var N=T.length;T.push(P);e:for(;0<N;){var G=N-1>>>1,F=T[G];if(0<o(F,P))T[G]=P,T[N]=F,N=G;else break e}}function n(T){return T.length===0?null:T[0]}function r(T){if(T.length===0)return null;var P=T[0],N=T.pop();if(N!==P){T[0]=N;e:for(var G=0,F=T.length,de=F>>>1;G<de;){var ne=2*(G+1)-1,ie=T[ne],Ie=ne+1,Ke=T[Ie];if(0>o(ie,N))Ie<F&&0>o(Ke,ie)?(T[G]=Ke,T[Ie]=N,G=Ie):(T[G]=ie,T[ne]=N,G=ne);else if(Ie<F&&0>o(Ke,N))T[G]=Ke,T[Ie]=N,G=Ie;else break e}}return P}function o(T,P){var N=T.sortIndex-P.sortIndex;return N!==0?N:T.id-P.id}if(typeof performance=="object"&&typeof performance.now=="function"){var i=performance;e.unstable_now=function(){return i.now()}}else{var l=Date,a=l.now();e.unstable_now=function(){return l.now()-a}}var s=[],c=[],m=1,h=null,f=3,w=!1,v=!1,k=!1,_=typeof setTimeout=="function"?setTimeout:null,p=typeof clearTimeout=="function"?clearTimeout:null,d=typeof setImmediate<"u"?setImmediate:null;typeof navigator<"u"&&navigator.scheduling!==void 0&&navigator.scheduling.isInputPending!==void 0&&navigator.scheduling.isInputPending.bind(navigator.scheduling);function g(T){for(var P=n(c);P!==null;){if(P.callback===null)r(c);else if(P.startTime<=T)r(c),P.sortIndex=P.expirationTime,t(s,P);else break;P=n(c)}}function S(T){if(k=!1,g(T),!v)if(n(s)!==null)v=!0,_e(y);else{var P=n(c);P!==null&&ce(S,P.startTime-T)}}function y(T,P){v=!1,k&&(k=!1,p($),$=-1),w=!0;var N=f;try{for(g(P),h=n(s);h!==null&&(!(h.expirationTime>P)||T&&!D());){var G=h.callback;if(typeof G=="function"){h.callback=null,f=h.priorityLevel;var F=G(h.expirationTime<=P);P=e.unstable_now(),typeof F=="function"?h.callback=F:h===n(s)&&r(s),g(P)}else r(s);h=n(s)}if(h!==null)var de=!0;else{var ne=n(c);ne!==null&&ce(S,ne.startTime-P),de=!1}return de}finally{h=null,f=N,w=!1}}var C=!1,b=null,$=-1,R=5,O=-1;function D(){return!(e.unstable_now()-O<R)}function W(){if(b!==null){var T=e.unstable_now();O=T;var P=!0;try{P=b(!0,T)}finally{P?z():(C=!1,b=null)}}else C=!1}var z;if(typeof d=="function")z=function(){d(W)};else if(typeof MessageChannel<"u"){var Ae=new MessageChannel,ht=Ae.port2;Ae.port1.onmessage=W,z=function(){ht.postMessage(null)}}else z=function(){_(W,0)};function _e(T){b=T,C||(C=!0,z())}function ce(T,P){$=_(function(){T(e.unstable_now())},P)}e.unstable_IdlePriority=5,e.unstable_ImmediatePriority=1,e.unstable_LowPriority=4,e.unstable_NormalPriority=3,e.unstable_Profiling=null,e.unstable_UserBlockingPriority=2,e.unstable_cancelCallback=function(T){T.callback=null},e.unstable_continueExecution=function(){v||w||(v=!0,_e(y))},e.unstable_forceFrameRate=function(T){0>T||125<T?console.error("forceFrameRate takes a positive int between 0 and 125, forcing frame rates higher than 125 fps is not supported"):R=0<T?Math.floor(1e3/T):5},e.unstable_getCurrentPriorityLevel=function(){return f},e.unstable_getFirstCallbackNode=function(){return n(s)},e.unstable_next=function(T){switch(f){case 1:case 2:case 3:var P=3;break;default:P=f}var N=f;f=P;try{return T()}finally{f=N}},e.unstable_pauseExecution=function(){},e.unstable_requestPaint=function(){},e.unstable_runWithPriority=function(T,P){switch(T){case 1:case 2:case 3:case 4:case 5:break;default:T=3}var N=f;f=T;try{return P()}finally{f=N}},e.unstable_scheduleCallback=function(T,P,N){var G=e.unstable_now();switch(typeof N=="object"&&N!==null?(N=N.delay,N=typeof N=="number"&&0<N?G+N:G):N=G,T){case 1:var F=-1;break;case 2:F=250;break;case 5:F=1073741823;break;case 4:F=1e4;break;default:F=5e3}return F=N+F,T={id:m++,callback:P,priorityLevel:T,startTime:N,expirationTime:F,sortIndex:-1},N>G?(T.sortIndex=N,t(c,T),n(s)===null&&T===n(c)&&(k?(p($),$=-1):k=!0,ce(S,N-G))):(T.sortIndex=F,t(s,T),v||w||(v=!0,_e(y))),T},e.unstable_shouldYield=D,e.unstable_wrapCallback=function(T){var P=f;return function(){var N=f;f=P;try{return T.apply(this,arguments)}finally{f=N}}}})(ld);id.exports=ld;var $0=id.exports;/**
 * @license React
 * react-dom.production.min.js
 *
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */var b0=j,Ue=$0;function E(e){for(var t="https://reactjs.org/docs/error-decoder.html?invariant="+e,n=1;n<arguments.length;n++)t+="&args[]="+encodeURIComponent(arguments[n]);return"Minified React error #"+e+"; visit "+t+" for the full message or use the non-minified dev environment for full errors and additional helpful warnings."}var ad=new Set,Gr={};function Sn(e,t){Xn(e,t),Xn(e+"Capture",t)}function Xn(e,t){for(Gr[e]=t,e=0;e<t.length;e++)ad.add(t[e])}var jt=!(typeof window>"u"||typeof window.document>"u"||typeof window.document.createElement>"u"),Vl=Object.prototype.hasOwnProperty,C0=/^[:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD][:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\-.0-9\u00B7\u0300-\u036F\u203F-\u2040]*$/,su={},uu={};function _0(e){return Vl.call(uu,e)?!0:Vl.call(su,e)?!1:C0.test(e)?uu[e]=!0:(su[e]=!0,!1)}function E0(e,t,n,r){if(n!==null&&n.type===0)return!1;switch(typeof t){case"function":case"symbol":return!0;case"boolean":return r?!1:n!==null?!n.acceptsBooleans:(e=e.toLowerCase().slice(0,5),e!=="data-"&&e!=="aria-");default:return!1}}function j0(e,t,n,r){if(t===null||typeof t>"u"||E0(e,t,n,r))return!0;if(r)return!1;if(n!==null)switch(n.type){case 3:return!t;case 4:return t===!1;case 5:return isNaN(t);case 6:return isNaN(t)||1>t}return!1}function Pe(e,t,n,r,o,i,l){this.acceptsBooleans=t===2||t===3||t===4,this.attributeName=r,this.attributeNamespace=o,this.mustUseProperty=n,this.propertyName=e,this.type=t,this.sanitizeURL=i,this.removeEmptyString=l}var we={};"children dangerouslySetInnerHTML defaultValue defaultChecked innerHTML suppressContentEditableWarning suppressHydrationWarning style".split(" ").forEach(function(e){we[e]=new Pe(e,0,!1,e,null,!1,!1)});[["acceptCharset","accept-charset"],["className","class"],["htmlFor","for"],["httpEquiv","http-equiv"]].forEach(function(e){var t=e[0];we[t]=new Pe(t,1,!1,e[1],null,!1,!1)});["contentEditable","draggable","spellCheck","value"].forEach(function(e){we[e]=new Pe(e,2,!1,e.toLowerCase(),null,!1,!1)});["autoReverse","externalResourcesRequired","focusable","preserveAlpha"].forEach(function(e){we[e]=new Pe(e,2,!1,e,null,!1,!1)});"allowFullScreen async autoFocus autoPlay controls default defer disabled disablePictureInPicture disableRemotePlayback formNoValidate hidden loop noModule noValidate open playsInline readOnly required reversed scoped seamless itemScope".split(" ").forEach(function(e){we[e]=new Pe(e,3,!1,e.toLowerCase(),null,!1,!1)});["checked","multiple","muted","selected"].forEach(function(e){we[e]=new Pe(e,3,!0,e,null,!1,!1)});["capture","download"].forEach(function(e){we[e]=new Pe(e,4,!1,e,null,!1,!1)});["cols","rows","size","span"].forEach(function(e){we[e]=new Pe(e,6,!1,e,null,!1,!1)});["rowSpan","start"].forEach(function(e){we[e]=new Pe(e,5,!1,e.toLowerCase(),null,!1,!1)});var Ja=/[\-:]([a-z])/g;function qa(e){return e[1].toUpperCase()}"accent-height alignment-baseline arabic-form baseline-shift cap-height clip-path clip-rule color-interpolation color-interpolation-filters color-profile color-rendering dominant-baseline enable-background fill-opacity fill-rule flood-color flood-opacity font-family font-size font-size-adjust font-stretch font-style font-variant font-weight glyph-name glyph-orientation-horizontal glyph-orientation-vertical horiz-adv-x horiz-origin-x image-rendering letter-spacing lighting-color marker-end marker-mid marker-start overline-position overline-thickness paint-order panose-1 pointer-events rendering-intent shape-rendering stop-color stop-opacity strikethrough-position strikethrough-thickness stroke-dasharray stroke-dashoffset stroke-linecap stroke-linejoin stroke-miterlimit stroke-opacity stroke-width text-anchor text-decoration text-rendering underline-position underline-thickness unicode-bidi unicode-range units-per-em v-alphabetic v-hanging v-ideographic v-mathematical vector-effect vert-adv-y vert-origin-x vert-origin-y word-spacing writing-mode xmlns:xlink x-height".split(" ").forEach(function(e){var t=e.replace(Ja,qa);we[t]=new Pe(t,1,!1,e,null,!1,!1)});"xlink:actuate xlink:arcrole xlink:role xlink:show xlink:title xlink:type".split(" ").forEach(function(e){var t=e.replace(Ja,qa);we[t]=new Pe(t,1,!1,e,"http://www.w3.org/1999/xlink",!1,!1)});["xml:base","xml:lang","xml:space"].forEach(function(e){var t=e.replace(Ja,qa);we[t]=new Pe(t,1,!1,e,"http://www.w3.org/XML/1998/namespace",!1,!1)});["tabIndex","crossOrigin"].forEach(function(e){we[e]=new Pe(e,1,!1,e.toLowerCase(),null,!1,!1)});we.xlinkHref=new Pe("xlinkHref",1,!1,"xlink:href","http://www.w3.org/1999/xlink",!0,!1);["src","href","action","formAction"].forEach(function(e){we[e]=new Pe(e,1,!1,e.toLowerCase(),null,!0,!0)});function es(e,t,n,r){var o=we.hasOwnProperty(t)?we[t]:null;(o!==null?o.type!==0:r||!(2<t.length)||t[0]!=="o"&&t[0]!=="O"||t[1]!=="n"&&t[1]!=="N")&&(j0(t,n,o,r)&&(n=null),r||o===null?_0(t)&&(n===null?e.removeAttribute(t):e.setAttribute(t,""+n)):o.mustUseProperty?e[o.propertyName]=n===null?o.type===3?!1:"":n:(t=o.attributeName,r=o.attributeNamespace,n===null?e.removeAttribute(t):(o=o.type,n=o===3||o===4&&n===!0?"":""+n,r?e.setAttributeNS(r,t,n):e.setAttribute(t,n))))}var Nt=b0.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED,_o=Symbol.for("react.element"),Nn=Symbol.for("react.portal"),On=Symbol.for("react.fragment"),ts=Symbol.for("react.strict_mode"),Gl=Symbol.for("react.profiler"),sd=Symbol.for("react.provider"),ud=Symbol.for("react.context"),ns=Symbol.for("react.forward_ref"),Kl=Symbol.for("react.suspense"),Yl=Symbol.for("react.suspense_list"),rs=Symbol.for("react.memo"),zt=Symbol.for("react.lazy"),cd=Symbol.for("react.offscreen"),cu=Symbol.iterator;function mr(e){return e===null||typeof e!="object"?null:(e=cu&&e[cu]||e["@@iterator"],typeof e=="function"?e:null)}var te=Object.assign,sl;function Cr(e){if(sl===void 0)try{throw Error()}catch(n){var t=n.stack.trim().match(/\n( *(at )?)/);sl=t&&t[1]||""}return`
`+sl+e}var ul=!1;function cl(e,t){if(!e||ul)return"";ul=!0;var n=Error.prepareStackTrace;Error.prepareStackTrace=void 0;try{if(t)if(t=function(){throw Error()},Object.defineProperty(t.prototype,"props",{set:function(){throw Error()}}),typeof Reflect=="object"&&Reflect.construct){try{Reflect.construct(t,[])}catch(c){var r=c}Reflect.construct(e,[],t)}else{try{t.call()}catch(c){r=c}e.call(t.prototype)}else{try{throw Error()}catch(c){r=c}e()}}catch(c){if(c&&r&&typeof c.stack=="string"){for(var o=c.stack.split(`
`),i=r.stack.split(`
`),l=o.length-1,a=i.length-1;1<=l&&0<=a&&o[l]!==i[a];)a--;for(;1<=l&&0<=a;l--,a--)if(o[l]!==i[a]){if(l!==1||a!==1)do if(l--,a--,0>a||o[l]!==i[a]){var s=`
`+o[l].replace(" at new "," at ");return e.displayName&&s.includes("<anonymous>")&&(s=s.replace("<anonymous>",e.displayName)),s}while(1<=l&&0<=a);break}}}finally{ul=!1,Error.prepareStackTrace=n}return(e=e?e.displayName||e.name:"")?Cr(e):""}function T0(e){switch(e.tag){case 5:return Cr(e.type);case 16:return Cr("Lazy");case 13:return Cr("Suspense");case 19:return Cr("SuspenseList");case 0:case 2:case 15:return e=cl(e.type,!1),e;case 11:return e=cl(e.type.render,!1),e;case 1:return e=cl(e.type,!0),e;default:return""}}function Ql(e){if(e==null)return null;if(typeof e=="function")return e.displayName||e.name||null;if(typeof e=="string")return e;switch(e){case On:return"Fragment";case Nn:return"Portal";case Gl:return"Profiler";case ts:return"StrictMode";case Kl:return"Suspense";case Yl:return"SuspenseList"}if(typeof e=="object")switch(e.$$typeof){case ud:return(e.displayName||"Context")+".Consumer";case sd:return(e._context.displayName||"Context")+".Provider";case ns:var t=e.render;return e=e.displayName,e||(e=t.displayName||t.name||"",e=e!==""?"ForwardRef("+e+")":"ForwardRef"),e;case rs:return t=e.displayName||null,t!==null?t:Ql(e.type)||"Memo";case zt:t=e._payload,e=e._init;try{return Ql(e(t))}catch{}}return null}function L0(e){var t=e.type;switch(e.tag){case 24:return"Cache";case 9:return(t.displayName||"Context")+".Consumer";case 10:return(t._context.displayName||"Context")+".Provider";case 18:return"DehydratedFragment";case 11:return e=t.render,e=e.displayName||e.name||"",t.displayName||(e!==""?"ForwardRef("+e+")":"ForwardRef");case 7:return"Fragment";case 5:return t;case 4:return"Portal";case 3:return"Root";case 6:return"Text";case 16:return Ql(t);case 8:return t===ts?"StrictMode":"Mode";case 22:return"Offscreen";case 12:return"Profiler";case 21:return"Scope";case 13:return"Suspense";case 19:return"SuspenseList";case 25:return"TracingMarker";case 1:case 0:case 17:case 2:case 14:case 15:if(typeof t=="function")return t.displayName||t.name||null;if(typeof t=="string")return t}return null}function en(e){switch(typeof e){case"boolean":case"number":case"string":case"undefined":return e;case"object":return e;default:return""}}function dd(e){var t=e.type;return(e=e.nodeName)&&e.toLowerCase()==="input"&&(t==="checkbox"||t==="radio")}function P0(e){var t=dd(e)?"checked":"value",n=Object.getOwnPropertyDescriptor(e.constructor.prototype,t),r=""+e[t];if(!e.hasOwnProperty(t)&&typeof n<"u"&&typeof n.get=="function"&&typeof n.set=="function"){var o=n.get,i=n.set;return Object.defineProperty(e,t,{configurable:!0,get:function(){return o.call(this)},set:function(l){r=""+l,i.call(this,l)}}),Object.defineProperty(e,t,{enumerable:n.enumerable}),{getValue:function(){return r},setValue:function(l){r=""+l},stopTracking:function(){e._valueTracker=null,delete e[t]}}}}function Eo(e){e._valueTracker||(e._valueTracker=P0(e))}function fd(e){if(!e)return!1;var t=e._valueTracker;if(!t)return!0;var n=t.getValue(),r="";return e&&(r=dd(e)?e.checked?"true":"false":e.value),e=r,e!==n?(t.setValue(e),!0):!1}function ai(e){if(e=e||(typeof document<"u"?document:void 0),typeof e>"u")return null;try{return e.activeElement||e.body}catch{return e.body}}function Zl(e,t){var n=t.checked;return te({},t,{defaultChecked:void 0,defaultValue:void 0,value:void 0,checked:n??e._wrapperState.initialChecked})}function du(e,t){var n=t.defaultValue==null?"":t.defaultValue,r=t.checked!=null?t.checked:t.defaultChecked;n=en(t.value!=null?t.value:n),e._wrapperState={initialChecked:r,initialValue:n,controlled:t.type==="checkbox"||t.type==="radio"?t.checked!=null:t.value!=null}}function pd(e,t){t=t.checked,t!=null&&es(e,"checked",t,!1)}function Xl(e,t){pd(e,t);var n=en(t.value),r=t.type;if(n!=null)r==="number"?(n===0&&e.value===""||e.value!=n)&&(e.value=""+n):e.value!==""+n&&(e.value=""+n);else if(r==="submit"||r==="reset"){e.removeAttribute("value");return}t.hasOwnProperty("value")?Jl(e,t.type,n):t.hasOwnProperty("defaultValue")&&Jl(e,t.type,en(t.defaultValue)),t.checked==null&&t.defaultChecked!=null&&(e.defaultChecked=!!t.defaultChecked)}function fu(e,t,n){if(t.hasOwnProperty("value")||t.hasOwnProperty("defaultValue")){var r=t.type;if(!(r!=="submit"&&r!=="reset"||t.value!==void 0&&t.value!==null))return;t=""+e._wrapperState.initialValue,n||t===e.value||(e.value=t),e.defaultValue=t}n=e.name,n!==""&&(e.name=""),e.defaultChecked=!!e._wrapperState.initialChecked,n!==""&&(e.name=n)}function Jl(e,t,n){(t!=="number"||ai(e.ownerDocument)!==e)&&(n==null?e.defaultValue=""+e._wrapperState.initialValue:e.defaultValue!==""+n&&(e.defaultValue=""+n))}var _r=Array.isArray;function Wn(e,t,n,r){if(e=e.options,t){t={};for(var o=0;o<n.length;o++)t["$"+n[o]]=!0;for(n=0;n<e.length;n++)o=t.hasOwnProperty("$"+e[n].value),e[n].selected!==o&&(e[n].selected=o),o&&r&&(e[n].defaultSelected=!0)}else{for(n=""+en(n),t=null,o=0;o<e.length;o++){if(e[o].value===n){e[o].selected=!0,r&&(e[o].defaultSelected=!0);return}t!==null||e[o].disabled||(t=e[o])}t!==null&&(t.selected=!0)}}function ql(e,t){if(t.dangerouslySetInnerHTML!=null)throw Error(E(91));return te({},t,{value:void 0,defaultValue:void 0,children:""+e._wrapperState.initialValue})}function pu(e,t){var n=t.value;if(n==null){if(n=t.children,t=t.defaultValue,n!=null){if(t!=null)throw Error(E(92));if(_r(n)){if(1<n.length)throw Error(E(93));n=n[0]}t=n}t==null&&(t=""),n=t}e._wrapperState={initialValue:en(n)}}function hd(e,t){var n=en(t.value),r=en(t.defaultValue);n!=null&&(n=""+n,n!==e.value&&(e.value=n),t.defaultValue==null&&e.defaultValue!==n&&(e.defaultValue=n)),r!=null&&(e.defaultValue=""+r)}function hu(e){var t=e.textContent;t===e._wrapperState.initialValue&&t!==""&&t!==null&&(e.value=t)}function md(e){switch(e){case"svg":return"http://www.w3.org/2000/svg";case"math":return"http://www.w3.org/1998/Math/MathML";default:return"http://www.w3.org/1999/xhtml"}}function ea(e,t){return e==null||e==="http://www.w3.org/1999/xhtml"?md(t):e==="http://www.w3.org/2000/svg"&&t==="foreignObject"?"http://www.w3.org/1999/xhtml":e}var jo,gd=function(e){return typeof MSApp<"u"&&MSApp.execUnsafeLocalFunction?function(t,n,r,o){MSApp.execUnsafeLocalFunction(function(){return e(t,n,r,o)})}:e}(function(e,t){if(e.namespaceURI!=="http://www.w3.org/2000/svg"||"innerHTML"in e)e.innerHTML=t;else{for(jo=jo||document.createElement("div"),jo.innerHTML="<svg>"+t.valueOf().toString()+"</svg>",t=jo.firstChild;e.firstChild;)e.removeChild(e.firstChild);for(;t.firstChild;)e.appendChild(t.firstChild)}});function Kr(e,t){if(t){var n=e.firstChild;if(n&&n===e.lastChild&&n.nodeType===3){n.nodeValue=t;return}}e.textContent=t}var Nr={animationIterationCount:!0,aspectRatio:!0,borderImageOutset:!0,borderImageSlice:!0,borderImageWidth:!0,boxFlex:!0,boxFlexGroup:!0,boxOrdinalGroup:!0,columnCount:!0,columns:!0,flex:!0,flexGrow:!0,flexPositive:!0,flexShrink:!0,flexNegative:!0,flexOrder:!0,gridArea:!0,gridRow:!0,gridRowEnd:!0,gridRowSpan:!0,gridRowStart:!0,gridColumn:!0,gridColumnEnd:!0,gridColumnSpan:!0,gridColumnStart:!0,fontWeight:!0,lineClamp:!0,lineHeight:!0,opacity:!0,order:!0,orphans:!0,tabSize:!0,widows:!0,zIndex:!0,zoom:!0,fillOpacity:!0,floodOpacity:!0,stopOpacity:!0,strokeDasharray:!0,strokeDashoffset:!0,strokeMiterlimit:!0,strokeOpacity:!0,strokeWidth:!0},N0=["Webkit","ms","Moz","O"];Object.keys(Nr).forEach(function(e){N0.forEach(function(t){t=t+e.charAt(0).toUpperCase()+e.substring(1),Nr[t]=Nr[e]})});function yd(e,t,n){return t==null||typeof t=="boolean"||t===""?"":n||typeof t!="number"||t===0||Nr.hasOwnProperty(e)&&Nr[e]?(""+t).trim():t+"px"}function xd(e,t){e=e.style;for(var n in t)if(t.hasOwnProperty(n)){var r=n.indexOf("--")===0,o=yd(n,t[n],r);n==="float"&&(n="cssFloat"),r?e.setProperty(n,o):e[n]=o}}var O0=te({menuitem:!0},{area:!0,base:!0,br:!0,col:!0,embed:!0,hr:!0,img:!0,input:!0,keygen:!0,link:!0,meta:!0,param:!0,source:!0,track:!0,wbr:!0});function ta(e,t){if(t){if(O0[e]&&(t.children!=null||t.dangerouslySetInnerHTML!=null))throw Error(E(137,e));if(t.dangerouslySetInnerHTML!=null){if(t.children!=null)throw Error(E(60));if(typeof t.dangerouslySetInnerHTML!="object"||!("__html"in t.dangerouslySetInnerHTML))throw Error(E(61))}if(t.style!=null&&typeof t.style!="object")throw Error(E(62))}}function na(e,t){if(e.indexOf("-")===-1)return typeof t.is=="string";switch(e){case"annotation-xml":case"color-profile":case"font-face":case"font-face-src":case"font-face-uri":case"font-face-format":case"font-face-name":case"missing-glyph":return!1;default:return!0}}var ra=null;function os(e){return e=e.target||e.srcElement||window,e.correspondingUseElement&&(e=e.correspondingUseElement),e.nodeType===3?e.parentNode:e}var oa=null,Vn=null,Gn=null;function mu(e){if(e=mo(e)){if(typeof oa!="function")throw Error(E(280));var t=e.stateNode;t&&(t=Di(t),oa(e.stateNode,e.type,t))}}function vd(e){Vn?Gn?Gn.push(e):Gn=[e]:Vn=e}function wd(){if(Vn){var e=Vn,t=Gn;if(Gn=Vn=null,mu(e),t)for(e=0;e<t.length;e++)mu(t[e])}}function kd(e,t){return e(t)}function Sd(){}var dl=!1;function $d(e,t,n){if(dl)return e(t,n);dl=!0;try{return kd(e,t,n)}finally{dl=!1,(Vn!==null||Gn!==null)&&(Sd(),wd())}}function Yr(e,t){var n=e.stateNode;if(n===null)return null;var r=Di(n);if(r===null)return null;n=r[t];e:switch(t){case"onClick":case"onClickCapture":case"onDoubleClick":case"onDoubleClickCapture":case"onMouseDown":case"onMouseDownCapture":case"onMouseMove":case"onMouseMoveCapture":case"onMouseUp":case"onMouseUpCapture":case"onMouseEnter":(r=!r.disabled)||(e=e.type,r=!(e==="button"||e==="input"||e==="select"||e==="textarea")),e=!r;break e;default:e=!1}if(e)return null;if(n&&typeof n!="function")throw Error(E(231,t,typeof n));return n}var ia=!1;if(jt)try{var gr={};Object.defineProperty(gr,"passive",{get:function(){ia=!0}}),window.addEventListener("test",gr,gr),window.removeEventListener("test",gr,gr)}catch{ia=!1}function R0(e,t,n,r,o,i,l,a,s){var c=Array.prototype.slice.call(arguments,3);try{t.apply(n,c)}catch(m){this.onError(m)}}var Or=!1,si=null,ui=!1,la=null,M0={onError:function(e){Or=!0,si=e}};function z0(e,t,n,r,o,i,l,a,s){Or=!1,si=null,R0.apply(M0,arguments)}function A0(e,t,n,r,o,i,l,a,s){if(z0.apply(this,arguments),Or){if(Or){var c=si;Or=!1,si=null}else throw Error(E(198));ui||(ui=!0,la=c)}}function $n(e){var t=e,n=e;if(e.alternate)for(;t.return;)t=t.return;else{e=t;do t=e,t.flags&4098&&(n=t.return),e=t.return;while(e)}return t.tag===3?n:null}function bd(e){if(e.tag===13){var t=e.memoizedState;if(t===null&&(e=e.alternate,e!==null&&(t=e.memoizedState)),t!==null)return t.dehydrated}return null}function gu(e){if($n(e)!==e)throw Error(E(188))}function I0(e){var t=e.alternate;if(!t){if(t=$n(e),t===null)throw Error(E(188));return t!==e?null:e}for(var n=e,r=t;;){var o=n.return;if(o===null)break;var i=o.alternate;if(i===null){if(r=o.return,r!==null){n=r;continue}break}if(o.child===i.child){for(i=o.child;i;){if(i===n)return gu(o),e;if(i===r)return gu(o),t;i=i.sibling}throw Error(E(188))}if(n.return!==r.return)n=o,r=i;else{for(var l=!1,a=o.child;a;){if(a===n){l=!0,n=o,r=i;break}if(a===r){l=!0,r=o,n=i;break}a=a.sibling}if(!l){for(a=i.child;a;){if(a===n){l=!0,n=i,r=o;break}if(a===r){l=!0,r=i,n=o;break}a=a.sibling}if(!l)throw Error(E(189))}}if(n.alternate!==r)throw Error(E(190))}if(n.tag!==3)throw Error(E(188));return n.stateNode.current===n?e:t}function Cd(e){return e=I0(e),e!==null?_d(e):null}function _d(e){if(e.tag===5||e.tag===6)return e;for(e=e.child;e!==null;){var t=_d(e);if(t!==null)return t;e=e.sibling}return null}var Ed=Ue.unstable_scheduleCallback,yu=Ue.unstable_cancelCallback,B0=Ue.unstable_shouldYield,F0=Ue.unstable_requestPaint,oe=Ue.unstable_now,D0=Ue.unstable_getCurrentPriorityLevel,is=Ue.unstable_ImmediatePriority,jd=Ue.unstable_UserBlockingPriority,ci=Ue.unstable_NormalPriority,H0=Ue.unstable_LowPriority,Td=Ue.unstable_IdlePriority,Ai=null,vt=null;function U0(e){if(vt&&typeof vt.onCommitFiberRoot=="function")try{vt.onCommitFiberRoot(Ai,e,void 0,(e.current.flags&128)===128)}catch{}}var ut=Math.clz32?Math.clz32:G0,W0=Math.log,V0=Math.LN2;function G0(e){return e>>>=0,e===0?32:31-(W0(e)/V0|0)|0}var To=64,Lo=4194304;function Er(e){switch(e&-e){case 1:return 1;case 2:return 2;case 4:return 4;case 8:return 8;case 16:return 16;case 32:return 32;case 64:case 128:case 256:case 512:case 1024:case 2048:case 4096:case 8192:case 16384:case 32768:case 65536:case 131072:case 262144:case 524288:case 1048576:case 2097152:return e&4194240;case 4194304:case 8388608:case 16777216:case 33554432:case 67108864:return e&130023424;case 134217728:return 134217728;case 268435456:return 268435456;case 536870912:return 536870912;case 1073741824:return 1073741824;default:return e}}function di(e,t){var n=e.pendingLanes;if(n===0)return 0;var r=0,o=e.suspendedLanes,i=e.pingedLanes,l=n&268435455;if(l!==0){var a=l&~o;a!==0?r=Er(a):(i&=l,i!==0&&(r=Er(i)))}else l=n&~o,l!==0?r=Er(l):i!==0&&(r=Er(i));if(r===0)return 0;if(t!==0&&t!==r&&!(t&o)&&(o=r&-r,i=t&-t,o>=i||o===16&&(i&4194240)!==0))return t;if(r&4&&(r|=n&16),t=e.entangledLanes,t!==0)for(e=e.entanglements,t&=r;0<t;)n=31-ut(t),o=1<<n,r|=e[n],t&=~o;return r}function K0(e,t){switch(e){case 1:case 2:case 4:return t+250;case 8:case 16:case 32:case 64:case 128:case 256:case 512:case 1024:case 2048:case 4096:case 8192:case 16384:case 32768:case 65536:case 131072:case 262144:case 524288:case 1048576:case 2097152:return t+5e3;case 4194304:case 8388608:case 16777216:case 33554432:case 67108864:return-1;case 134217728:case 268435456:case 536870912:case 1073741824:return-1;default:return-1}}function Y0(e,t){for(var n=e.suspendedLanes,r=e.pingedLanes,o=e.expirationTimes,i=e.pendingLanes;0<i;){var l=31-ut(i),a=1<<l,s=o[l];s===-1?(!(a&n)||a&r)&&(o[l]=K0(a,t)):s<=t&&(e.expiredLanes|=a),i&=~a}}function aa(e){return e=e.pendingLanes&-1073741825,e!==0?e:e&1073741824?1073741824:0}function Ld(){var e=To;return To<<=1,!(To&4194240)&&(To=64),e}function fl(e){for(var t=[],n=0;31>n;n++)t.push(e);return t}function po(e,t,n){e.pendingLanes|=t,t!==536870912&&(e.suspendedLanes=0,e.pingedLanes=0),e=e.eventTimes,t=31-ut(t),e[t]=n}function Q0(e,t){var n=e.pendingLanes&~t;e.pendingLanes=t,e.suspendedLanes=0,e.pingedLanes=0,e.expiredLanes&=t,e.mutableReadLanes&=t,e.entangledLanes&=t,t=e.entanglements;var r=e.eventTimes;for(e=e.expirationTimes;0<n;){var o=31-ut(n),i=1<<o;t[o]=0,r[o]=-1,e[o]=-1,n&=~i}}function ls(e,t){var n=e.entangledLanes|=t;for(e=e.entanglements;n;){var r=31-ut(n),o=1<<r;o&t|e[r]&t&&(e[r]|=t),n&=~o}}var V=0;function Pd(e){return e&=-e,1<e?4<e?e&268435455?16:536870912:4:1}var Nd,as,Od,Rd,Md,sa=!1,Po=[],Wt=null,Vt=null,Gt=null,Qr=new Map,Zr=new Map,It=[],Z0="mousedown mouseup touchcancel touchend touchstart auxclick dblclick pointercancel pointerdown pointerup dragend dragstart drop compositionend compositionstart keydown keypress keyup input textInput copy cut paste click change contextmenu reset submit".split(" ");function xu(e,t){switch(e){case"focusin":case"focusout":Wt=null;break;case"dragenter":case"dragleave":Vt=null;break;case"mouseover":case"mouseout":Gt=null;break;case"pointerover":case"pointerout":Qr.delete(t.pointerId);break;case"gotpointercapture":case"lostpointercapture":Zr.delete(t.pointerId)}}function yr(e,t,n,r,o,i){return e===null||e.nativeEvent!==i?(e={blockedOn:t,domEventName:n,eventSystemFlags:r,nativeEvent:i,targetContainers:[o]},t!==null&&(t=mo(t),t!==null&&as(t)),e):(e.eventSystemFlags|=r,t=e.targetContainers,o!==null&&t.indexOf(o)===-1&&t.push(o),e)}function X0(e,t,n,r,o){switch(t){case"focusin":return Wt=yr(Wt,e,t,n,r,o),!0;case"dragenter":return Vt=yr(Vt,e,t,n,r,o),!0;case"mouseover":return Gt=yr(Gt,e,t,n,r,o),!0;case"pointerover":var i=o.pointerId;return Qr.set(i,yr(Qr.get(i)||null,e,t,n,r,o)),!0;case"gotpointercapture":return i=o.pointerId,Zr.set(i,yr(Zr.get(i)||null,e,t,n,r,o)),!0}return!1}function zd(e){var t=un(e.target);if(t!==null){var n=$n(t);if(n!==null){if(t=n.tag,t===13){if(t=bd(n),t!==null){e.blockedOn=t,Md(e.priority,function(){Od(n)});return}}else if(t===3&&n.stateNode.current.memoizedState.isDehydrated){e.blockedOn=n.tag===3?n.stateNode.containerInfo:null;return}}}e.blockedOn=null}function Vo(e){if(e.blockedOn!==null)return!1;for(var t=e.targetContainers;0<t.length;){var n=ua(e.domEventName,e.eventSystemFlags,t[0],e.nativeEvent);if(n===null){n=e.nativeEvent;var r=new n.constructor(n.type,n);ra=r,n.target.dispatchEvent(r),ra=null}else return t=mo(n),t!==null&&as(t),e.blockedOn=n,!1;t.shift()}return!0}function vu(e,t,n){Vo(e)&&n.delete(t)}function J0(){sa=!1,Wt!==null&&Vo(Wt)&&(Wt=null),Vt!==null&&Vo(Vt)&&(Vt=null),Gt!==null&&Vo(Gt)&&(Gt=null),Qr.forEach(vu),Zr.forEach(vu)}function xr(e,t){e.blockedOn===t&&(e.blockedOn=null,sa||(sa=!0,Ue.unstable_scheduleCallback(Ue.unstable_NormalPriority,J0)))}function Xr(e){function t(o){return xr(o,e)}if(0<Po.length){xr(Po[0],e);for(var n=1;n<Po.length;n++){var r=Po[n];r.blockedOn===e&&(r.blockedOn=null)}}for(Wt!==null&&xr(Wt,e),Vt!==null&&xr(Vt,e),Gt!==null&&xr(Gt,e),Qr.forEach(t),Zr.forEach(t),n=0;n<It.length;n++)r=It[n],r.blockedOn===e&&(r.blockedOn=null);for(;0<It.length&&(n=It[0],n.blockedOn===null);)zd(n),n.blockedOn===null&&It.shift()}var Kn=Nt.ReactCurrentBatchConfig,fi=!0;function q0(e,t,n,r){var o=V,i=Kn.transition;Kn.transition=null;try{V=1,ss(e,t,n,r)}finally{V=o,Kn.transition=i}}function eh(e,t,n,r){var o=V,i=Kn.transition;Kn.transition=null;try{V=4,ss(e,t,n,r)}finally{V=o,Kn.transition=i}}function ss(e,t,n,r){if(fi){var o=ua(e,t,n,r);if(o===null)Sl(e,t,r,pi,n),xu(e,r);else if(X0(o,e,t,n,r))r.stopPropagation();else if(xu(e,r),t&4&&-1<Z0.indexOf(e)){for(;o!==null;){var i=mo(o);if(i!==null&&Nd(i),i=ua(e,t,n,r),i===null&&Sl(e,t,r,pi,n),i===o)break;o=i}o!==null&&r.stopPropagation()}else Sl(e,t,r,null,n)}}var pi=null;function ua(e,t,n,r){if(pi=null,e=os(r),e=un(e),e!==null)if(t=$n(e),t===null)e=null;else if(n=t.tag,n===13){if(e=bd(t),e!==null)return e;e=null}else if(n===3){if(t.stateNode.current.memoizedState.isDehydrated)return t.tag===3?t.stateNode.containerInfo:null;e=null}else t!==e&&(e=null);return pi=e,null}function Ad(e){switch(e){case"cancel":case"click":case"close":case"contextmenu":case"copy":case"cut":case"auxclick":case"dblclick":case"dragend":case"dragstart":case"drop":case"focusin":case"focusout":case"input":case"invalid":case"keydown":case"keypress":case"keyup":case"mousedown":case"mouseup":case"paste":case"pause":case"play":case"pointercancel":case"pointerdown":case"pointerup":case"ratechange":case"reset":case"resize":case"seeked":case"submit":case"touchcancel":case"touchend":case"touchstart":case"volumechange":case"change":case"selectionchange":case"textInput":case"compositionstart":case"compositionend":case"compositionupdate":case"beforeblur":case"afterblur":case"beforeinput":case"blur":case"fullscreenchange":case"focus":case"hashchange":case"popstate":case"select":case"selectstart":return 1;case"drag":case"dragenter":case"dragexit":case"dragleave":case"dragover":case"mousemove":case"mouseout":case"mouseover":case"pointermove":case"pointerout":case"pointerover":case"scroll":case"toggle":case"touchmove":case"wheel":case"mouseenter":case"mouseleave":case"pointerenter":case"pointerleave":return 4;case"message":switch(D0()){case is:return 1;case jd:return 4;case ci:case H0:return 16;case Td:return 536870912;default:return 16}default:return 16}}var Ft=null,us=null,Go=null;function Id(){if(Go)return Go;var e,t=us,n=t.length,r,o="value"in Ft?Ft.value:Ft.textContent,i=o.length;for(e=0;e<n&&t[e]===o[e];e++);var l=n-e;for(r=1;r<=l&&t[n-r]===o[i-r];r++);return Go=o.slice(e,1<r?1-r:void 0)}function Ko(e){var t=e.keyCode;return"charCode"in e?(e=e.charCode,e===0&&t===13&&(e=13)):e=t,e===10&&(e=13),32<=e||e===13?e:0}function No(){return!0}function wu(){return!1}function Ve(e){function t(n,r,o,i,l){this._reactName=n,this._targetInst=o,this.type=r,this.nativeEvent=i,this.target=l,this.currentTarget=null;for(var a in e)e.hasOwnProperty(a)&&(n=e[a],this[a]=n?n(i):i[a]);return this.isDefaultPrevented=(i.defaultPrevented!=null?i.defaultPrevented:i.returnValue===!1)?No:wu,this.isPropagationStopped=wu,this}return te(t.prototype,{preventDefault:function(){this.defaultPrevented=!0;var n=this.nativeEvent;n&&(n.preventDefault?n.preventDefault():typeof n.returnValue!="unknown"&&(n.returnValue=!1),this.isDefaultPrevented=No)},stopPropagation:function(){var n=this.nativeEvent;n&&(n.stopPropagation?n.stopPropagation():typeof n.cancelBubble!="unknown"&&(n.cancelBubble=!0),this.isPropagationStopped=No)},persist:function(){},isPersistent:No}),t}var cr={eventPhase:0,bubbles:0,cancelable:0,timeStamp:function(e){return e.timeStamp||Date.now()},defaultPrevented:0,isTrusted:0},cs=Ve(cr),ho=te({},cr,{view:0,detail:0}),th=Ve(ho),pl,hl,vr,Ii=te({},ho,{screenX:0,screenY:0,clientX:0,clientY:0,pageX:0,pageY:0,ctrlKey:0,shiftKey:0,altKey:0,metaKey:0,getModifierState:ds,button:0,buttons:0,relatedTarget:function(e){return e.relatedTarget===void 0?e.fromElement===e.srcElement?e.toElement:e.fromElement:e.relatedTarget},movementX:function(e){return"movementX"in e?e.movementX:(e!==vr&&(vr&&e.type==="mousemove"?(pl=e.screenX-vr.screenX,hl=e.screenY-vr.screenY):hl=pl=0,vr=e),pl)},movementY:function(e){return"movementY"in e?e.movementY:hl}}),ku=Ve(Ii),nh=te({},Ii,{dataTransfer:0}),rh=Ve(nh),oh=te({},ho,{relatedTarget:0}),ml=Ve(oh),ih=te({},cr,{animationName:0,elapsedTime:0,pseudoElement:0}),lh=Ve(ih),ah=te({},cr,{clipboardData:function(e){return"clipboardData"in e?e.clipboardData:window.clipboardData}}),sh=Ve(ah),uh=te({},cr,{data:0}),Su=Ve(uh),ch={Esc:"Escape",Spacebar:" ",Left:"ArrowLeft",Up:"ArrowUp",Right:"ArrowRight",Down:"ArrowDown",Del:"Delete",Win:"OS",Menu:"ContextMenu",Apps:"ContextMenu",Scroll:"ScrollLock",MozPrintableKey:"Unidentified"},dh={8:"Backspace",9:"Tab",12:"Clear",13:"Enter",16:"Shift",17:"Control",18:"Alt",19:"Pause",20:"CapsLock",27:"Escape",32:" ",33:"PageUp",34:"PageDown",35:"End",36:"Home",37:"ArrowLeft",38:"ArrowUp",39:"ArrowRight",40:"ArrowDown",45:"Insert",46:"Delete",112:"F1",113:"F2",114:"F3",115:"F4",116:"F5",117:"F6",118:"F7",119:"F8",120:"F9",121:"F10",122:"F11",123:"F12",144:"NumLock",145:"ScrollLock",224:"Meta"},fh={Alt:"altKey",Control:"ctrlKey",Meta:"metaKey",Shift:"shiftKey"};function ph(e){var t=this.nativeEvent;return t.getModifierState?t.getModifierState(e):(e=fh[e])?!!t[e]:!1}function ds(){return ph}var hh=te({},ho,{key:function(e){if(e.key){var t=ch[e.key]||e.key;if(t!=="Unidentified")return t}return e.type==="keypress"?(e=Ko(e),e===13?"Enter":String.fromCharCode(e)):e.type==="keydown"||e.type==="keyup"?dh[e.keyCode]||"Unidentified":""},code:0,location:0,ctrlKey:0,shiftKey:0,altKey:0,metaKey:0,repeat:0,locale:0,getModifierState:ds,charCode:function(e){return e.type==="keypress"?Ko(e):0},keyCode:function(e){return e.type==="keydown"||e.type==="keyup"?e.keyCode:0},which:function(e){return e.type==="keypress"?Ko(e):e.type==="keydown"||e.type==="keyup"?e.keyCode:0}}),mh=Ve(hh),gh=te({},Ii,{pointerId:0,width:0,height:0,pressure:0,tangentialPressure:0,tiltX:0,tiltY:0,twist:0,pointerType:0,isPrimary:0}),$u=Ve(gh),yh=te({},ho,{touches:0,targetTouches:0,changedTouches:0,altKey:0,metaKey:0,ctrlKey:0,shiftKey:0,getModifierState:ds}),xh=Ve(yh),vh=te({},cr,{propertyName:0,elapsedTime:0,pseudoElement:0}),wh=Ve(vh),kh=te({},Ii,{deltaX:function(e){return"deltaX"in e?e.deltaX:"wheelDeltaX"in e?-e.wheelDeltaX:0},deltaY:function(e){return"deltaY"in e?e.deltaY:"wheelDeltaY"in e?-e.wheelDeltaY:"wheelDelta"in e?-e.wheelDelta:0},deltaZ:0,deltaMode:0}),Sh=Ve(kh),$h=[9,13,27,32],fs=jt&&"CompositionEvent"in window,Rr=null;jt&&"documentMode"in document&&(Rr=document.documentMode);var bh=jt&&"TextEvent"in window&&!Rr,Bd=jt&&(!fs||Rr&&8<Rr&&11>=Rr),bu=" ",Cu=!1;function Fd(e,t){switch(e){case"keyup":return $h.indexOf(t.keyCode)!==-1;case"keydown":return t.keyCode!==229;case"keypress":case"mousedown":case"focusout":return!0;default:return!1}}function Dd(e){return e=e.detail,typeof e=="object"&&"data"in e?e.data:null}var Rn=!1;function Ch(e,t){switch(e){case"compositionend":return Dd(t);case"keypress":return t.which!==32?null:(Cu=!0,bu);case"textInput":return e=t.data,e===bu&&Cu?null:e;default:return null}}function _h(e,t){if(Rn)return e==="compositionend"||!fs&&Fd(e,t)?(e=Id(),Go=us=Ft=null,Rn=!1,e):null;switch(e){case"paste":return null;case"keypress":if(!(t.ctrlKey||t.altKey||t.metaKey)||t.ctrlKey&&t.altKey){if(t.char&&1<t.char.length)return t.char;if(t.which)return String.fromCharCode(t.which)}return null;case"compositionend":return Bd&&t.locale!=="ko"?null:t.data;default:return null}}var Eh={color:!0,date:!0,datetime:!0,"datetime-local":!0,email:!0,month:!0,number:!0,password:!0,range:!0,search:!0,tel:!0,text:!0,time:!0,url:!0,week:!0};function _u(e){var t=e&&e.nodeName&&e.nodeName.toLowerCase();return t==="input"?!!Eh[e.type]:t==="textarea"}function Hd(e,t,n,r){vd(r),t=hi(t,"onChange"),0<t.length&&(n=new cs("onChange","change",null,n,r),e.push({event:n,listeners:t}))}var Mr=null,Jr=null;function jh(e){qd(e,0)}function Bi(e){var t=An(e);if(fd(t))return e}function Th(e,t){if(e==="change")return t}var Ud=!1;if(jt){var gl;if(jt){var yl="oninput"in document;if(!yl){var Eu=document.createElement("div");Eu.setAttribute("oninput","return;"),yl=typeof Eu.oninput=="function"}gl=yl}else gl=!1;Ud=gl&&(!document.documentMode||9<document.documentMode)}function ju(){Mr&&(Mr.detachEvent("onpropertychange",Wd),Jr=Mr=null)}function Wd(e){if(e.propertyName==="value"&&Bi(Jr)){var t=[];Hd(t,Jr,e,os(e)),$d(jh,t)}}function Lh(e,t,n){e==="focusin"?(ju(),Mr=t,Jr=n,Mr.attachEvent("onpropertychange",Wd)):e==="focusout"&&ju()}function Ph(e){if(e==="selectionchange"||e==="keyup"||e==="keydown")return Bi(Jr)}function Nh(e,t){if(e==="click")return Bi(t)}function Oh(e,t){if(e==="input"||e==="change")return Bi(t)}function Rh(e,t){return e===t&&(e!==0||1/e===1/t)||e!==e&&t!==t}var ft=typeof Object.is=="function"?Object.is:Rh;function qr(e,t){if(ft(e,t))return!0;if(typeof e!="object"||e===null||typeof t!="object"||t===null)return!1;var n=Object.keys(e),r=Object.keys(t);if(n.length!==r.length)return!1;for(r=0;r<n.length;r++){var o=n[r];if(!Vl.call(t,o)||!ft(e[o],t[o]))return!1}return!0}function Tu(e){for(;e&&e.firstChild;)e=e.firstChild;return e}function Lu(e,t){var n=Tu(e);e=0;for(var r;n;){if(n.nodeType===3){if(r=e+n.textContent.length,e<=t&&r>=t)return{node:n,offset:t-e};e=r}e:{for(;n;){if(n.nextSibling){n=n.nextSibling;break e}n=n.parentNode}n=void 0}n=Tu(n)}}function Vd(e,t){return e&&t?e===t?!0:e&&e.nodeType===3?!1:t&&t.nodeType===3?Vd(e,t.parentNode):"contains"in e?e.contains(t):e.compareDocumentPosition?!!(e.compareDocumentPosition(t)&16):!1:!1}function Gd(){for(var e=window,t=ai();t instanceof e.HTMLIFrameElement;){try{var n=typeof t.contentWindow.location.href=="string"}catch{n=!1}if(n)e=t.contentWindow;else break;t=ai(e.document)}return t}function ps(e){var t=e&&e.nodeName&&e.nodeName.toLowerCase();return t&&(t==="input"&&(e.type==="text"||e.type==="search"||e.type==="tel"||e.type==="url"||e.type==="password")||t==="textarea"||e.contentEditable==="true")}function Mh(e){var t=Gd(),n=e.focusedElem,r=e.selectionRange;if(t!==n&&n&&n.ownerDocument&&Vd(n.ownerDocument.documentElement,n)){if(r!==null&&ps(n)){if(t=r.start,e=r.end,e===void 0&&(e=t),"selectionStart"in n)n.selectionStart=t,n.selectionEnd=Math.min(e,n.value.length);else if(e=(t=n.ownerDocument||document)&&t.defaultView||window,e.getSelection){e=e.getSelection();var o=n.textContent.length,i=Math.min(r.start,o);r=r.end===void 0?i:Math.min(r.end,o),!e.extend&&i>r&&(o=r,r=i,i=o),o=Lu(n,i);var l=Lu(n,r);o&&l&&(e.rangeCount!==1||e.anchorNode!==o.node||e.anchorOffset!==o.offset||e.focusNode!==l.node||e.focusOffset!==l.offset)&&(t=t.createRange(),t.setStart(o.node,o.offset),e.removeAllRanges(),i>r?(e.addRange(t),e.extend(l.node,l.offset)):(t.setEnd(l.node,l.offset),e.addRange(t)))}}for(t=[],e=n;e=e.parentNode;)e.nodeType===1&&t.push({element:e,left:e.scrollLeft,top:e.scrollTop});for(typeof n.focus=="function"&&n.focus(),n=0;n<t.length;n++)e=t[n],e.element.scrollLeft=e.left,e.element.scrollTop=e.top}}var zh=jt&&"documentMode"in document&&11>=document.documentMode,Mn=null,ca=null,zr=null,da=!1;function Pu(e,t,n){var r=n.window===n?n.document:n.nodeType===9?n:n.ownerDocument;da||Mn==null||Mn!==ai(r)||(r=Mn,"selectionStart"in r&&ps(r)?r={start:r.selectionStart,end:r.selectionEnd}:(r=(r.ownerDocument&&r.ownerDocument.defaultView||window).getSelection(),r={anchorNode:r.anchorNode,anchorOffset:r.anchorOffset,focusNode:r.focusNode,focusOffset:r.focusOffset}),zr&&qr(zr,r)||(zr=r,r=hi(ca,"onSelect"),0<r.length&&(t=new cs("onSelect","select",null,t,n),e.push({event:t,listeners:r}),t.target=Mn)))}function Oo(e,t){var n={};return n[e.toLowerCase()]=t.toLowerCase(),n["Webkit"+e]="webkit"+t,n["Moz"+e]="moz"+t,n}var zn={animationend:Oo("Animation","AnimationEnd"),animationiteration:Oo("Animation","AnimationIteration"),animationstart:Oo("Animation","AnimationStart"),transitionend:Oo("Transition","TransitionEnd")},xl={},Kd={};jt&&(Kd=document.createElement("div").style,"AnimationEvent"in window||(delete zn.animationend.animation,delete zn.animationiteration.animation,delete zn.animationstart.animation),"TransitionEvent"in window||delete zn.transitionend.transition);function Fi(e){if(xl[e])return xl[e];if(!zn[e])return e;var t=zn[e],n;for(n in t)if(t.hasOwnProperty(n)&&n in Kd)return xl[e]=t[n];return e}var Yd=Fi("animationend"),Qd=Fi("animationiteration"),Zd=Fi("animationstart"),Xd=Fi("transitionend"),Jd=new Map,Nu="abort auxClick cancel canPlay canPlayThrough click close contextMenu copy cut drag dragEnd dragEnter dragExit dragLeave dragOver dragStart drop durationChange emptied encrypted ended error gotPointerCapture input invalid keyDown keyPress keyUp load loadedData loadedMetadata loadStart lostPointerCapture mouseDown mouseMove mouseOut mouseOver mouseUp paste pause play playing pointerCancel pointerDown pointerMove pointerOut pointerOver pointerUp progress rateChange reset resize seeked seeking stalled submit suspend timeUpdate touchCancel touchEnd touchStart volumeChange scroll toggle touchMove waiting wheel".split(" ");function nn(e,t){Jd.set(e,t),Sn(t,[e])}for(var vl=0;vl<Nu.length;vl++){var wl=Nu[vl],Ah=wl.toLowerCase(),Ih=wl[0].toUpperCase()+wl.slice(1);nn(Ah,"on"+Ih)}nn(Yd,"onAnimationEnd");nn(Qd,"onAnimationIteration");nn(Zd,"onAnimationStart");nn("dblclick","onDoubleClick");nn("focusin","onFocus");nn("focusout","onBlur");nn(Xd,"onTransitionEnd");Xn("onMouseEnter",["mouseout","mouseover"]);Xn("onMouseLeave",["mouseout","mouseover"]);Xn("onPointerEnter",["pointerout","pointerover"]);Xn("onPointerLeave",["pointerout","pointerover"]);Sn("onChange","change click focusin focusout input keydown keyup selectionchange".split(" "));Sn("onSelect","focusout contextmenu dragend focusin keydown keyup mousedown mouseup selectionchange".split(" "));Sn("onBeforeInput",["compositionend","keypress","textInput","paste"]);Sn("onCompositionEnd","compositionend focusout keydown keypress keyup mousedown".split(" "));Sn("onCompositionStart","compositionstart focusout keydown keypress keyup mousedown".split(" "));Sn("onCompositionUpdate","compositionupdate focusout keydown keypress keyup mousedown".split(" "));var jr="abort canplay canplaythrough durationchange emptied encrypted ended error loadeddata loadedmetadata loadstart pause play playing progress ratechange resize seeked seeking stalled suspend timeupdate volumechange waiting".split(" "),Bh=new Set("cancel close invalid load scroll toggle".split(" ").concat(jr));function Ou(e,t,n){var r=e.type||"unknown-event";e.currentTarget=n,A0(r,t,void 0,e),e.currentTarget=null}function qd(e,t){t=(t&4)!==0;for(var n=0;n<e.length;n++){var r=e[n],o=r.event;r=r.listeners;e:{var i=void 0;if(t)for(var l=r.length-1;0<=l;l--){var a=r[l],s=a.instance,c=a.currentTarget;if(a=a.listener,s!==i&&o.isPropagationStopped())break e;Ou(o,a,c),i=s}else for(l=0;l<r.length;l++){if(a=r[l],s=a.instance,c=a.currentTarget,a=a.listener,s!==i&&o.isPropagationStopped())break e;Ou(o,a,c),i=s}}}if(ui)throw e=la,ui=!1,la=null,e}function Y(e,t){var n=t[ga];n===void 0&&(n=t[ga]=new Set);var r=e+"__bubble";n.has(r)||(ef(t,e,2,!1),n.add(r))}function kl(e,t,n){var r=0;t&&(r|=4),ef(n,e,r,t)}var Ro="_reactListening"+Math.random().toString(36).slice(2);function eo(e){if(!e[Ro]){e[Ro]=!0,ad.forEach(function(n){n!=="selectionchange"&&(Bh.has(n)||kl(n,!1,e),kl(n,!0,e))});var t=e.nodeType===9?e:e.ownerDocument;t===null||t[Ro]||(t[Ro]=!0,kl("selectionchange",!1,t))}}function ef(e,t,n,r){switch(Ad(t)){case 1:var o=q0;break;case 4:o=eh;break;default:o=ss}n=o.bind(null,t,n,e),o=void 0,!ia||t!=="touchstart"&&t!=="touchmove"&&t!=="wheel"||(o=!0),r?o!==void 0?e.addEventListener(t,n,{capture:!0,passive:o}):e.addEventListener(t,n,!0):o!==void 0?e.addEventListener(t,n,{passive:o}):e.addEventListener(t,n,!1)}function Sl(e,t,n,r,o){var i=r;if(!(t&1)&&!(t&2)&&r!==null)e:for(;;){if(r===null)return;var l=r.tag;if(l===3||l===4){var a=r.stateNode.containerInfo;if(a===o||a.nodeType===8&&a.parentNode===o)break;if(l===4)for(l=r.return;l!==null;){var s=l.tag;if((s===3||s===4)&&(s=l.stateNode.containerInfo,s===o||s.nodeType===8&&s.parentNode===o))return;l=l.return}for(;a!==null;){if(l=un(a),l===null)return;if(s=l.tag,s===5||s===6){r=i=l;continue e}a=a.parentNode}}r=r.return}$d(function(){var c=i,m=os(n),h=[];e:{var f=Jd.get(e);if(f!==void 0){var w=cs,v=e;switch(e){case"keypress":if(Ko(n)===0)break e;case"keydown":case"keyup":w=mh;break;case"focusin":v="focus",w=ml;break;case"focusout":v="blur",w=ml;break;case"beforeblur":case"afterblur":w=ml;break;case"click":if(n.button===2)break e;case"auxclick":case"dblclick":case"mousedown":case"mousemove":case"mouseup":case"mouseout":case"mouseover":case"contextmenu":w=ku;break;case"drag":case"dragend":case"dragenter":case"dragexit":case"dragleave":case"dragover":case"dragstart":case"drop":w=rh;break;case"touchcancel":case"touchend":case"touchmove":case"touchstart":w=xh;break;case Yd:case Qd:case Zd:w=lh;break;case Xd:w=wh;break;case"scroll":w=th;break;case"wheel":w=Sh;break;case"copy":case"cut":case"paste":w=sh;break;case"gotpointercapture":case"lostpointercapture":case"pointercancel":case"pointerdown":case"pointermove":case"pointerout":case"pointerover":case"pointerup":w=$u}var k=(t&4)!==0,_=!k&&e==="scroll",p=k?f!==null?f+"Capture":null:f;k=[];for(var d=c,g;d!==null;){g=d;var S=g.stateNode;if(g.tag===5&&S!==null&&(g=S,p!==null&&(S=Yr(d,p),S!=null&&k.push(to(d,S,g)))),_)break;d=d.return}0<k.length&&(f=new w(f,v,null,n,m),h.push({event:f,listeners:k}))}}if(!(t&7)){e:{if(f=e==="mouseover"||e==="pointerover",w=e==="mouseout"||e==="pointerout",f&&n!==ra&&(v=n.relatedTarget||n.fromElement)&&(un(v)||v[Tt]))break e;if((w||f)&&(f=m.window===m?m:(f=m.ownerDocument)?f.defaultView||f.parentWindow:window,w?(v=n.relatedTarget||n.toElement,w=c,v=v?un(v):null,v!==null&&(_=$n(v),v!==_||v.tag!==5&&v.tag!==6)&&(v=null)):(w=null,v=c),w!==v)){if(k=ku,S="onMouseLeave",p="onMouseEnter",d="mouse",(e==="pointerout"||e==="pointerover")&&(k=$u,S="onPointerLeave",p="onPointerEnter",d="pointer"),_=w==null?f:An(w),g=v==null?f:An(v),f=new k(S,d+"leave",w,n,m),f.target=_,f.relatedTarget=g,S=null,un(m)===c&&(k=new k(p,d+"enter",v,n,m),k.target=g,k.relatedTarget=_,S=k),_=S,w&&v)t:{for(k=w,p=v,d=0,g=k;g;g=_n(g))d++;for(g=0,S=p;S;S=_n(S))g++;for(;0<d-g;)k=_n(k),d--;for(;0<g-d;)p=_n(p),g--;for(;d--;){if(k===p||p!==null&&k===p.alternate)break t;k=_n(k),p=_n(p)}k=null}else k=null;w!==null&&Ru(h,f,w,k,!1),v!==null&&_!==null&&Ru(h,_,v,k,!0)}}e:{if(f=c?An(c):window,w=f.nodeName&&f.nodeName.toLowerCase(),w==="select"||w==="input"&&f.type==="file")var y=Th;else if(_u(f))if(Ud)y=Oh;else{y=Ph;var C=Lh}else(w=f.nodeName)&&w.toLowerCase()==="input"&&(f.type==="checkbox"||f.type==="radio")&&(y=Nh);if(y&&(y=y(e,c))){Hd(h,y,n,m);break e}C&&C(e,f,c),e==="focusout"&&(C=f._wrapperState)&&C.controlled&&f.type==="number"&&Jl(f,"number",f.value)}switch(C=c?An(c):window,e){case"focusin":(_u(C)||C.contentEditable==="true")&&(Mn=C,ca=c,zr=null);break;case"focusout":zr=ca=Mn=null;break;case"mousedown":da=!0;break;case"contextmenu":case"mouseup":case"dragend":da=!1,Pu(h,n,m);break;case"selectionchange":if(zh)break;case"keydown":case"keyup":Pu(h,n,m)}var b;if(fs)e:{switch(e){case"compositionstart":var $="onCompositionStart";break e;case"compositionend":$="onCompositionEnd";break e;case"compositionupdate":$="onCompositionUpdate";break e}$=void 0}else Rn?Fd(e,n)&&($="onCompositionEnd"):e==="keydown"&&n.keyCode===229&&($="onCompositionStart");$&&(Bd&&n.locale!=="ko"&&(Rn||$!=="onCompositionStart"?$==="onCompositionEnd"&&Rn&&(b=Id()):(Ft=m,us="value"in Ft?Ft.value:Ft.textContent,Rn=!0)),C=hi(c,$),0<C.length&&($=new Su($,e,null,n,m),h.push({event:$,listeners:C}),b?$.data=b:(b=Dd(n),b!==null&&($.data=b)))),(b=bh?Ch(e,n):_h(e,n))&&(c=hi(c,"onBeforeInput"),0<c.length&&(m=new Su("onBeforeInput","beforeinput",null,n,m),h.push({event:m,listeners:c}),m.data=b))}qd(h,t)})}function to(e,t,n){return{instance:e,listener:t,currentTarget:n}}function hi(e,t){for(var n=t+"Capture",r=[];e!==null;){var o=e,i=o.stateNode;o.tag===5&&i!==null&&(o=i,i=Yr(e,n),i!=null&&r.unshift(to(e,i,o)),i=Yr(e,t),i!=null&&r.push(to(e,i,o))),e=e.return}return r}function _n(e){if(e===null)return null;do e=e.return;while(e&&e.tag!==5);return e||null}function Ru(e,t,n,r,o){for(var i=t._reactName,l=[];n!==null&&n!==r;){var a=n,s=a.alternate,c=a.stateNode;if(s!==null&&s===r)break;a.tag===5&&c!==null&&(a=c,o?(s=Yr(n,i),s!=null&&l.unshift(to(n,s,a))):o||(s=Yr(n,i),s!=null&&l.push(to(n,s,a)))),n=n.return}l.length!==0&&e.push({event:t,listeners:l})}var Fh=/\r\n?/g,Dh=/\u0000|\uFFFD/g;function Mu(e){return(typeof e=="string"?e:""+e).replace(Fh,`
`).replace(Dh,"")}function Mo(e,t,n){if(t=Mu(t),Mu(e)!==t&&n)throw Error(E(425))}function mi(){}var fa=null,pa=null;function ha(e,t){return e==="textarea"||e==="noscript"||typeof t.children=="string"||typeof t.children=="number"||typeof t.dangerouslySetInnerHTML=="object"&&t.dangerouslySetInnerHTML!==null&&t.dangerouslySetInnerHTML.__html!=null}var ma=typeof setTimeout=="function"?setTimeout:void 0,Hh=typeof clearTimeout=="function"?clearTimeout:void 0,zu=typeof Promise=="function"?Promise:void 0,Uh=typeof queueMicrotask=="function"?queueMicrotask:typeof zu<"u"?function(e){return zu.resolve(null).then(e).catch(Wh)}:ma;function Wh(e){setTimeout(function(){throw e})}function $l(e,t){var n=t,r=0;do{var o=n.nextSibling;if(e.removeChild(n),o&&o.nodeType===8)if(n=o.data,n==="/$"){if(r===0){e.removeChild(o),Xr(t);return}r--}else n!=="$"&&n!=="$?"&&n!=="$!"||r++;n=o}while(n);Xr(t)}function Kt(e){for(;e!=null;e=e.nextSibling){var t=e.nodeType;if(t===1||t===3)break;if(t===8){if(t=e.data,t==="$"||t==="$!"||t==="$?")break;if(t==="/$")return null}}return e}function Au(e){e=e.previousSibling;for(var t=0;e;){if(e.nodeType===8){var n=e.data;if(n==="$"||n==="$!"||n==="$?"){if(t===0)return e;t--}else n==="/$"&&t++}e=e.previousSibling}return null}var dr=Math.random().toString(36).slice(2),xt="__reactFiber$"+dr,no="__reactProps$"+dr,Tt="__reactContainer$"+dr,ga="__reactEvents$"+dr,Vh="__reactListeners$"+dr,Gh="__reactHandles$"+dr;function un(e){var t=e[xt];if(t)return t;for(var n=e.parentNode;n;){if(t=n[Tt]||n[xt]){if(n=t.alternate,t.child!==null||n!==null&&n.child!==null)for(e=Au(e);e!==null;){if(n=e[xt])return n;e=Au(e)}return t}e=n,n=e.parentNode}return null}function mo(e){return e=e[xt]||e[Tt],!e||e.tag!==5&&e.tag!==6&&e.tag!==13&&e.tag!==3?null:e}function An(e){if(e.tag===5||e.tag===6)return e.stateNode;throw Error(E(33))}function Di(e){return e[no]||null}var ya=[],In=-1;function rn(e){return{current:e}}function Z(e){0>In||(e.current=ya[In],ya[In]=null,In--)}function K(e,t){In++,ya[In]=e.current,e.current=t}var tn={},Ce=rn(tn),Re=rn(!1),gn=tn;function Jn(e,t){var n=e.type.contextTypes;if(!n)return tn;var r=e.stateNode;if(r&&r.__reactInternalMemoizedUnmaskedChildContext===t)return r.__reactInternalMemoizedMaskedChildContext;var o={},i;for(i in n)o[i]=t[i];return r&&(e=e.stateNode,e.__reactInternalMemoizedUnmaskedChildContext=t,e.__reactInternalMemoizedMaskedChildContext=o),o}function Me(e){return e=e.childContextTypes,e!=null}function gi(){Z(Re),Z(Ce)}function Iu(e,t,n){if(Ce.current!==tn)throw Error(E(168));K(Ce,t),K(Re,n)}function tf(e,t,n){var r=e.stateNode;if(t=t.childContextTypes,typeof r.getChildContext!="function")return n;r=r.getChildContext();for(var o in r)if(!(o in t))throw Error(E(108,L0(e)||"Unknown",o));return te({},n,r)}function yi(e){return e=(e=e.stateNode)&&e.__reactInternalMemoizedMergedChildContext||tn,gn=Ce.current,K(Ce,e),K(Re,Re.current),!0}function Bu(e,t,n){var r=e.stateNode;if(!r)throw Error(E(169));n?(e=tf(e,t,gn),r.__reactInternalMemoizedMergedChildContext=e,Z(Re),Z(Ce),K(Ce,e)):Z(Re),K(Re,n)}var bt=null,Hi=!1,bl=!1;function nf(e){bt===null?bt=[e]:bt.push(e)}function Kh(e){Hi=!0,nf(e)}function on(){if(!bl&&bt!==null){bl=!0;var e=0,t=V;try{var n=bt;for(V=1;e<n.length;e++){var r=n[e];do r=r(!0);while(r!==null)}bt=null,Hi=!1}catch(o){throw bt!==null&&(bt=bt.slice(e+1)),Ed(is,on),o}finally{V=t,bl=!1}}return null}var Bn=[],Fn=0,xi=null,vi=0,Ye=[],Qe=0,yn=null,Ct=1,_t="";function ln(e,t){Bn[Fn++]=vi,Bn[Fn++]=xi,xi=e,vi=t}function rf(e,t,n){Ye[Qe++]=Ct,Ye[Qe++]=_t,Ye[Qe++]=yn,yn=e;var r=Ct;e=_t;var o=32-ut(r)-1;r&=~(1<<o),n+=1;var i=32-ut(t)+o;if(30<i){var l=o-o%5;i=(r&(1<<l)-1).toString(32),r>>=l,o-=l,Ct=1<<32-ut(t)+o|n<<o|r,_t=i+e}else Ct=1<<i|n<<o|r,_t=e}function hs(e){e.return!==null&&(ln(e,1),rf(e,1,0))}function ms(e){for(;e===xi;)xi=Bn[--Fn],Bn[Fn]=null,vi=Bn[--Fn],Bn[Fn]=null;for(;e===yn;)yn=Ye[--Qe],Ye[Qe]=null,_t=Ye[--Qe],Ye[Qe]=null,Ct=Ye[--Qe],Ye[Qe]=null}var He=null,De=null,X=!1,at=null;function of(e,t){var n=Ze(5,null,null,0);n.elementType="DELETED",n.stateNode=t,n.return=e,t=e.deletions,t===null?(e.deletions=[n],e.flags|=16):t.push(n)}function Fu(e,t){switch(e.tag){case 5:var n=e.type;return t=t.nodeType!==1||n.toLowerCase()!==t.nodeName.toLowerCase()?null:t,t!==null?(e.stateNode=t,He=e,De=Kt(t.firstChild),!0):!1;case 6:return t=e.pendingProps===""||t.nodeType!==3?null:t,t!==null?(e.stateNode=t,He=e,De=null,!0):!1;case 13:return t=t.nodeType!==8?null:t,t!==null?(n=yn!==null?{id:Ct,overflow:_t}:null,e.memoizedState={dehydrated:t,treeContext:n,retryLane:1073741824},n=Ze(18,null,null,0),n.stateNode=t,n.return=e,e.child=n,He=e,De=null,!0):!1;default:return!1}}function xa(e){return(e.mode&1)!==0&&(e.flags&128)===0}function va(e){if(X){var t=De;if(t){var n=t;if(!Fu(e,t)){if(xa(e))throw Error(E(418));t=Kt(n.nextSibling);var r=He;t&&Fu(e,t)?of(r,n):(e.flags=e.flags&-4097|2,X=!1,He=e)}}else{if(xa(e))throw Error(E(418));e.flags=e.flags&-4097|2,X=!1,He=e}}}function Du(e){for(e=e.return;e!==null&&e.tag!==5&&e.tag!==3&&e.tag!==13;)e=e.return;He=e}function zo(e){if(e!==He)return!1;if(!X)return Du(e),X=!0,!1;var t;if((t=e.tag!==3)&&!(t=e.tag!==5)&&(t=e.type,t=t!=="head"&&t!=="body"&&!ha(e.type,e.memoizedProps)),t&&(t=De)){if(xa(e))throw lf(),Error(E(418));for(;t;)of(e,t),t=Kt(t.nextSibling)}if(Du(e),e.tag===13){if(e=e.memoizedState,e=e!==null?e.dehydrated:null,!e)throw Error(E(317));e:{for(e=e.nextSibling,t=0;e;){if(e.nodeType===8){var n=e.data;if(n==="/$"){if(t===0){De=Kt(e.nextSibling);break e}t--}else n!=="$"&&n!=="$!"&&n!=="$?"||t++}e=e.nextSibling}De=null}}else De=He?Kt(e.stateNode.nextSibling):null;return!0}function lf(){for(var e=De;e;)e=Kt(e.nextSibling)}function qn(){De=He=null,X=!1}function gs(e){at===null?at=[e]:at.push(e)}var Yh=Nt.ReactCurrentBatchConfig;function wr(e,t,n){if(e=n.ref,e!==null&&typeof e!="function"&&typeof e!="object"){if(n._owner){if(n=n._owner,n){if(n.tag!==1)throw Error(E(309));var r=n.stateNode}if(!r)throw Error(E(147,e));var o=r,i=""+e;return t!==null&&t.ref!==null&&typeof t.ref=="function"&&t.ref._stringRef===i?t.ref:(t=function(l){var a=o.refs;l===null?delete a[i]:a[i]=l},t._stringRef=i,t)}if(typeof e!="string")throw Error(E(284));if(!n._owner)throw Error(E(290,e))}return e}function Ao(e,t){throw e=Object.prototype.toString.call(t),Error(E(31,e==="[object Object]"?"object with keys {"+Object.keys(t).join(", ")+"}":e))}function Hu(e){var t=e._init;return t(e._payload)}function af(e){function t(p,d){if(e){var g=p.deletions;g===null?(p.deletions=[d],p.flags|=16):g.push(d)}}function n(p,d){if(!e)return null;for(;d!==null;)t(p,d),d=d.sibling;return null}function r(p,d){for(p=new Map;d!==null;)d.key!==null?p.set(d.key,d):p.set(d.index,d),d=d.sibling;return p}function o(p,d){return p=Xt(p,d),p.index=0,p.sibling=null,p}function i(p,d,g){return p.index=g,e?(g=p.alternate,g!==null?(g=g.index,g<d?(p.flags|=2,d):g):(p.flags|=2,d)):(p.flags|=1048576,d)}function l(p){return e&&p.alternate===null&&(p.flags|=2),p}function a(p,d,g,S){return d===null||d.tag!==6?(d=Pl(g,p.mode,S),d.return=p,d):(d=o(d,g),d.return=p,d)}function s(p,d,g,S){var y=g.type;return y===On?m(p,d,g.props.children,S,g.key):d!==null&&(d.elementType===y||typeof y=="object"&&y!==null&&y.$$typeof===zt&&Hu(y)===d.type)?(S=o(d,g.props),S.ref=wr(p,d,g),S.return=p,S):(S=ei(g.type,g.key,g.props,null,p.mode,S),S.ref=wr(p,d,g),S.return=p,S)}function c(p,d,g,S){return d===null||d.tag!==4||d.stateNode.containerInfo!==g.containerInfo||d.stateNode.implementation!==g.implementation?(d=Nl(g,p.mode,S),d.return=p,d):(d=o(d,g.children||[]),d.return=p,d)}function m(p,d,g,S,y){return d===null||d.tag!==7?(d=pn(g,p.mode,S,y),d.return=p,d):(d=o(d,g),d.return=p,d)}function h(p,d,g){if(typeof d=="string"&&d!==""||typeof d=="number")return d=Pl(""+d,p.mode,g),d.return=p,d;if(typeof d=="object"&&d!==null){switch(d.$$typeof){case _o:return g=ei(d.type,d.key,d.props,null,p.mode,g),g.ref=wr(p,null,d),g.return=p,g;case Nn:return d=Nl(d,p.mode,g),d.return=p,d;case zt:var S=d._init;return h(p,S(d._payload),g)}if(_r(d)||mr(d))return d=pn(d,p.mode,g,null),d.return=p,d;Ao(p,d)}return null}function f(p,d,g,S){var y=d!==null?d.key:null;if(typeof g=="string"&&g!==""||typeof g=="number")return y!==null?null:a(p,d,""+g,S);if(typeof g=="object"&&g!==null){switch(g.$$typeof){case _o:return g.key===y?s(p,d,g,S):null;case Nn:return g.key===y?c(p,d,g,S):null;case zt:return y=g._init,f(p,d,y(g._payload),S)}if(_r(g)||mr(g))return y!==null?null:m(p,d,g,S,null);Ao(p,g)}return null}function w(p,d,g,S,y){if(typeof S=="string"&&S!==""||typeof S=="number")return p=p.get(g)||null,a(d,p,""+S,y);if(typeof S=="object"&&S!==null){switch(S.$$typeof){case _o:return p=p.get(S.key===null?g:S.key)||null,s(d,p,S,y);case Nn:return p=p.get(S.key===null?g:S.key)||null,c(d,p,S,y);case zt:var C=S._init;return w(p,d,g,C(S._payload),y)}if(_r(S)||mr(S))return p=p.get(g)||null,m(d,p,S,y,null);Ao(d,S)}return null}function v(p,d,g,S){for(var y=null,C=null,b=d,$=d=0,R=null;b!==null&&$<g.length;$++){b.index>$?(R=b,b=null):R=b.sibling;var O=f(p,b,g[$],S);if(O===null){b===null&&(b=R);break}e&&b&&O.alternate===null&&t(p,b),d=i(O,d,$),C===null?y=O:C.sibling=O,C=O,b=R}if($===g.length)return n(p,b),X&&ln(p,$),y;if(b===null){for(;$<g.length;$++)b=h(p,g[$],S),b!==null&&(d=i(b,d,$),C===null?y=b:C.sibling=b,C=b);return X&&ln(p,$),y}for(b=r(p,b);$<g.length;$++)R=w(b,p,$,g[$],S),R!==null&&(e&&R.alternate!==null&&b.delete(R.key===null?$:R.key),d=i(R,d,$),C===null?y=R:C.sibling=R,C=R);return e&&b.forEach(function(D){return t(p,D)}),X&&ln(p,$),y}function k(p,d,g,S){var y=mr(g);if(typeof y!="function")throw Error(E(150));if(g=y.call(g),g==null)throw Error(E(151));for(var C=y=null,b=d,$=d=0,R=null,O=g.next();b!==null&&!O.done;$++,O=g.next()){b.index>$?(R=b,b=null):R=b.sibling;var D=f(p,b,O.value,S);if(D===null){b===null&&(b=R);break}e&&b&&D.alternate===null&&t(p,b),d=i(D,d,$),C===null?y=D:C.sibling=D,C=D,b=R}if(O.done)return n(p,b),X&&ln(p,$),y;if(b===null){for(;!O.done;$++,O=g.next())O=h(p,O.value,S),O!==null&&(d=i(O,d,$),C===null?y=O:C.sibling=O,C=O);return X&&ln(p,$),y}for(b=r(p,b);!O.done;$++,O=g.next())O=w(b,p,$,O.value,S),O!==null&&(e&&O.alternate!==null&&b.delete(O.key===null?$:O.key),d=i(O,d,$),C===null?y=O:C.sibling=O,C=O);return e&&b.forEach(function(W){return t(p,W)}),X&&ln(p,$),y}function _(p,d,g,S){if(typeof g=="object"&&g!==null&&g.type===On&&g.key===null&&(g=g.props.children),typeof g=="object"&&g!==null){switch(g.$$typeof){case _o:e:{for(var y=g.key,C=d;C!==null;){if(C.key===y){if(y=g.type,y===On){if(C.tag===7){n(p,C.sibling),d=o(C,g.props.children),d.return=p,p=d;break e}}else if(C.elementType===y||typeof y=="object"&&y!==null&&y.$$typeof===zt&&Hu(y)===C.type){n(p,C.sibling),d=o(C,g.props),d.ref=wr(p,C,g),d.return=p,p=d;break e}n(p,C);break}else t(p,C);C=C.sibling}g.type===On?(d=pn(g.props.children,p.mode,S,g.key),d.return=p,p=d):(S=ei(g.type,g.key,g.props,null,p.mode,S),S.ref=wr(p,d,g),S.return=p,p=S)}return l(p);case Nn:e:{for(C=g.key;d!==null;){if(d.key===C)if(d.tag===4&&d.stateNode.containerInfo===g.containerInfo&&d.stateNode.implementation===g.implementation){n(p,d.sibling),d=o(d,g.children||[]),d.return=p,p=d;break e}else{n(p,d);break}else t(p,d);d=d.sibling}d=Nl(g,p.mode,S),d.return=p,p=d}return l(p);case zt:return C=g._init,_(p,d,C(g._payload),S)}if(_r(g))return v(p,d,g,S);if(mr(g))return k(p,d,g,S);Ao(p,g)}return typeof g=="string"&&g!==""||typeof g=="number"?(g=""+g,d!==null&&d.tag===6?(n(p,d.sibling),d=o(d,g),d.return=p,p=d):(n(p,d),d=Pl(g,p.mode,S),d.return=p,p=d),l(p)):n(p,d)}return _}var er=af(!0),sf=af(!1),wi=rn(null),ki=null,Dn=null,ys=null;function xs(){ys=Dn=ki=null}function vs(e){var t=wi.current;Z(wi),e._currentValue=t}function wa(e,t,n){for(;e!==null;){var r=e.alternate;if((e.childLanes&t)!==t?(e.childLanes|=t,r!==null&&(r.childLanes|=t)):r!==null&&(r.childLanes&t)!==t&&(r.childLanes|=t),e===n)break;e=e.return}}function Yn(e,t){ki=e,ys=Dn=null,e=e.dependencies,e!==null&&e.firstContext!==null&&(e.lanes&t&&(Oe=!0),e.firstContext=null)}function Je(e){var t=e._currentValue;if(ys!==e)if(e={context:e,memoizedValue:t,next:null},Dn===null){if(ki===null)throw Error(E(308));Dn=e,ki.dependencies={lanes:0,firstContext:e}}else Dn=Dn.next=e;return t}var cn=null;function ws(e){cn===null?cn=[e]:cn.push(e)}function uf(e,t,n,r){var o=t.interleaved;return o===null?(n.next=n,ws(t)):(n.next=o.next,o.next=n),t.interleaved=n,Lt(e,r)}function Lt(e,t){e.lanes|=t;var n=e.alternate;for(n!==null&&(n.lanes|=t),n=e,e=e.return;e!==null;)e.childLanes|=t,n=e.alternate,n!==null&&(n.childLanes|=t),n=e,e=e.return;return n.tag===3?n.stateNode:null}var At=!1;function ks(e){e.updateQueue={baseState:e.memoizedState,firstBaseUpdate:null,lastBaseUpdate:null,shared:{pending:null,interleaved:null,lanes:0},effects:null}}function cf(e,t){e=e.updateQueue,t.updateQueue===e&&(t.updateQueue={baseState:e.baseState,firstBaseUpdate:e.firstBaseUpdate,lastBaseUpdate:e.lastBaseUpdate,shared:e.shared,effects:e.effects})}function Et(e,t){return{eventTime:e,lane:t,tag:0,payload:null,callback:null,next:null}}function Yt(e,t,n){var r=e.updateQueue;if(r===null)return null;if(r=r.shared,B&2){var o=r.pending;return o===null?t.next=t:(t.next=o.next,o.next=t),r.pending=t,Lt(e,n)}return o=r.interleaved,o===null?(t.next=t,ws(r)):(t.next=o.next,o.next=t),r.interleaved=t,Lt(e,n)}function Yo(e,t,n){if(t=t.updateQueue,t!==null&&(t=t.shared,(n&4194240)!==0)){var r=t.lanes;r&=e.pendingLanes,n|=r,t.lanes=n,ls(e,n)}}function Uu(e,t){var n=e.updateQueue,r=e.alternate;if(r!==null&&(r=r.updateQueue,n===r)){var o=null,i=null;if(n=n.firstBaseUpdate,n!==null){do{var l={eventTime:n.eventTime,lane:n.lane,tag:n.tag,payload:n.payload,callback:n.callback,next:null};i===null?o=i=l:i=i.next=l,n=n.next}while(n!==null);i===null?o=i=t:i=i.next=t}else o=i=t;n={baseState:r.baseState,firstBaseUpdate:o,lastBaseUpdate:i,shared:r.shared,effects:r.effects},e.updateQueue=n;return}e=n.lastBaseUpdate,e===null?n.firstBaseUpdate=t:e.next=t,n.lastBaseUpdate=t}function Si(e,t,n,r){var o=e.updateQueue;At=!1;var i=o.firstBaseUpdate,l=o.lastBaseUpdate,a=o.shared.pending;if(a!==null){o.shared.pending=null;var s=a,c=s.next;s.next=null,l===null?i=c:l.next=c,l=s;var m=e.alternate;m!==null&&(m=m.updateQueue,a=m.lastBaseUpdate,a!==l&&(a===null?m.firstBaseUpdate=c:a.next=c,m.lastBaseUpdate=s))}if(i!==null){var h=o.baseState;l=0,m=c=s=null,a=i;do{var f=a.lane,w=a.eventTime;if((r&f)===f){m!==null&&(m=m.next={eventTime:w,lane:0,tag:a.tag,payload:a.payload,callback:a.callback,next:null});e:{var v=e,k=a;switch(f=t,w=n,k.tag){case 1:if(v=k.payload,typeof v=="function"){h=v.call(w,h,f);break e}h=v;break e;case 3:v.flags=v.flags&-65537|128;case 0:if(v=k.payload,f=typeof v=="function"?v.call(w,h,f):v,f==null)break e;h=te({},h,f);break e;case 2:At=!0}}a.callback!==null&&a.lane!==0&&(e.flags|=64,f=o.effects,f===null?o.effects=[a]:f.push(a))}else w={eventTime:w,lane:f,tag:a.tag,payload:a.payload,callback:a.callback,next:null},m===null?(c=m=w,s=h):m=m.next=w,l|=f;if(a=a.next,a===null){if(a=o.shared.pending,a===null)break;f=a,a=f.next,f.next=null,o.lastBaseUpdate=f,o.shared.pending=null}}while(!0);if(m===null&&(s=h),o.baseState=s,o.firstBaseUpdate=c,o.lastBaseUpdate=m,t=o.shared.interleaved,t!==null){o=t;do l|=o.lane,o=o.next;while(o!==t)}else i===null&&(o.shared.lanes=0);vn|=l,e.lanes=l,e.memoizedState=h}}function Wu(e,t,n){if(e=t.effects,t.effects=null,e!==null)for(t=0;t<e.length;t++){var r=e[t],o=r.callback;if(o!==null){if(r.callback=null,r=n,typeof o!="function")throw Error(E(191,o));o.call(r)}}}var go={},wt=rn(go),ro=rn(go),oo=rn(go);function dn(e){if(e===go)throw Error(E(174));return e}function Ss(e,t){switch(K(oo,t),K(ro,e),K(wt,go),e=t.nodeType,e){case 9:case 11:t=(t=t.documentElement)?t.namespaceURI:ea(null,"");break;default:e=e===8?t.parentNode:t,t=e.namespaceURI||null,e=e.tagName,t=ea(t,e)}Z(wt),K(wt,t)}function tr(){Z(wt),Z(ro),Z(oo)}function df(e){dn(oo.current);var t=dn(wt.current),n=ea(t,e.type);t!==n&&(K(ro,e),K(wt,n))}function $s(e){ro.current===e&&(Z(wt),Z(ro))}var J=rn(0);function $i(e){for(var t=e;t!==null;){if(t.tag===13){var n=t.memoizedState;if(n!==null&&(n=n.dehydrated,n===null||n.data==="$?"||n.data==="$!"))return t}else if(t.tag===19&&t.memoizedProps.revealOrder!==void 0){if(t.flags&128)return t}else if(t.child!==null){t.child.return=t,t=t.child;continue}if(t===e)break;for(;t.sibling===null;){if(t.return===null||t.return===e)return null;t=t.return}t.sibling.return=t.return,t=t.sibling}return null}var Cl=[];function bs(){for(var e=0;e<Cl.length;e++)Cl[e]._workInProgressVersionPrimary=null;Cl.length=0}var Qo=Nt.ReactCurrentDispatcher,_l=Nt.ReactCurrentBatchConfig,xn=0,ee=null,fe=null,me=null,bi=!1,Ar=!1,io=0,Qh=0;function ke(){throw Error(E(321))}function Cs(e,t){if(t===null)return!1;for(var n=0;n<t.length&&n<e.length;n++)if(!ft(e[n],t[n]))return!1;return!0}function _s(e,t,n,r,o,i){if(xn=i,ee=t,t.memoizedState=null,t.updateQueue=null,t.lanes=0,Qo.current=e===null||e.memoizedState===null?qh:em,e=n(r,o),Ar){i=0;do{if(Ar=!1,io=0,25<=i)throw Error(E(301));i+=1,me=fe=null,t.updateQueue=null,Qo.current=tm,e=n(r,o)}while(Ar)}if(Qo.current=Ci,t=fe!==null&&fe.next!==null,xn=0,me=fe=ee=null,bi=!1,t)throw Error(E(300));return e}function Es(){var e=io!==0;return io=0,e}function gt(){var e={memoizedState:null,baseState:null,baseQueue:null,queue:null,next:null};return me===null?ee.memoizedState=me=e:me=me.next=e,me}function qe(){if(fe===null){var e=ee.alternate;e=e!==null?e.memoizedState:null}else e=fe.next;var t=me===null?ee.memoizedState:me.next;if(t!==null)me=t,fe=e;else{if(e===null)throw Error(E(310));fe=e,e={memoizedState:fe.memoizedState,baseState:fe.baseState,baseQueue:fe.baseQueue,queue:fe.queue,next:null},me===null?ee.memoizedState=me=e:me=me.next=e}return me}function lo(e,t){return typeof t=="function"?t(e):t}function El(e){var t=qe(),n=t.queue;if(n===null)throw Error(E(311));n.lastRenderedReducer=e;var r=fe,o=r.baseQueue,i=n.pending;if(i!==null){if(o!==null){var l=o.next;o.next=i.next,i.next=l}r.baseQueue=o=i,n.pending=null}if(o!==null){i=o.next,r=r.baseState;var a=l=null,s=null,c=i;do{var m=c.lane;if((xn&m)===m)s!==null&&(s=s.next={lane:0,action:c.action,hasEagerState:c.hasEagerState,eagerState:c.eagerState,next:null}),r=c.hasEagerState?c.eagerState:e(r,c.action);else{var h={lane:m,action:c.action,hasEagerState:c.hasEagerState,eagerState:c.eagerState,next:null};s===null?(a=s=h,l=r):s=s.next=h,ee.lanes|=m,vn|=m}c=c.next}while(c!==null&&c!==i);s===null?l=r:s.next=a,ft(r,t.memoizedState)||(Oe=!0),t.memoizedState=r,t.baseState=l,t.baseQueue=s,n.lastRenderedState=r}if(e=n.interleaved,e!==null){o=e;do i=o.lane,ee.lanes|=i,vn|=i,o=o.next;while(o!==e)}else o===null&&(n.lanes=0);return[t.memoizedState,n.dispatch]}function jl(e){var t=qe(),n=t.queue;if(n===null)throw Error(E(311));n.lastRenderedReducer=e;var r=n.dispatch,o=n.pending,i=t.memoizedState;if(o!==null){n.pending=null;var l=o=o.next;do i=e(i,l.action),l=l.next;while(l!==o);ft(i,t.memoizedState)||(Oe=!0),t.memoizedState=i,t.baseQueue===null&&(t.baseState=i),n.lastRenderedState=i}return[i,r]}function ff(){}function pf(e,t){var n=ee,r=qe(),o=t(),i=!ft(r.memoizedState,o);if(i&&(r.memoizedState=o,Oe=!0),r=r.queue,js(gf.bind(null,n,r,e),[e]),r.getSnapshot!==t||i||me!==null&&me.memoizedState.tag&1){if(n.flags|=2048,ao(9,mf.bind(null,n,r,o,t),void 0,null),ge===null)throw Error(E(349));xn&30||hf(n,t,o)}return o}function hf(e,t,n){e.flags|=16384,e={getSnapshot:t,value:n},t=ee.updateQueue,t===null?(t={lastEffect:null,stores:null},ee.updateQueue=t,t.stores=[e]):(n=t.stores,n===null?t.stores=[e]:n.push(e))}function mf(e,t,n,r){t.value=n,t.getSnapshot=r,yf(t)&&xf(e)}function gf(e,t,n){return n(function(){yf(t)&&xf(e)})}function yf(e){var t=e.getSnapshot;e=e.value;try{var n=t();return!ft(e,n)}catch{return!0}}function xf(e){var t=Lt(e,1);t!==null&&ct(t,e,1,-1)}function Vu(e){var t=gt();return typeof e=="function"&&(e=e()),t.memoizedState=t.baseState=e,e={pending:null,interleaved:null,lanes:0,dispatch:null,lastRenderedReducer:lo,lastRenderedState:e},t.queue=e,e=e.dispatch=Jh.bind(null,ee,e),[t.memoizedState,e]}function ao(e,t,n,r){return e={tag:e,create:t,destroy:n,deps:r,next:null},t=ee.updateQueue,t===null?(t={lastEffect:null,stores:null},ee.updateQueue=t,t.lastEffect=e.next=e):(n=t.lastEffect,n===null?t.lastEffect=e.next=e:(r=n.next,n.next=e,e.next=r,t.lastEffect=e)),e}function vf(){return qe().memoizedState}function Zo(e,t,n,r){var o=gt();ee.flags|=e,o.memoizedState=ao(1|t,n,void 0,r===void 0?null:r)}function Ui(e,t,n,r){var o=qe();r=r===void 0?null:r;var i=void 0;if(fe!==null){var l=fe.memoizedState;if(i=l.destroy,r!==null&&Cs(r,l.deps)){o.memoizedState=ao(t,n,i,r);return}}ee.flags|=e,o.memoizedState=ao(1|t,n,i,r)}function Gu(e,t){return Zo(8390656,8,e,t)}function js(e,t){return Ui(2048,8,e,t)}function wf(e,t){return Ui(4,2,e,t)}function kf(e,t){return Ui(4,4,e,t)}function Sf(e,t){if(typeof t=="function")return e=e(),t(e),function(){t(null)};if(t!=null)return e=e(),t.current=e,function(){t.current=null}}function $f(e,t,n){return n=n!=null?n.concat([e]):null,Ui(4,4,Sf.bind(null,t,e),n)}function Ts(){}function bf(e,t){var n=qe();t=t===void 0?null:t;var r=n.memoizedState;return r!==null&&t!==null&&Cs(t,r[1])?r[0]:(n.memoizedState=[e,t],e)}function Cf(e,t){var n=qe();t=t===void 0?null:t;var r=n.memoizedState;return r!==null&&t!==null&&Cs(t,r[1])?r[0]:(e=e(),n.memoizedState=[e,t],e)}function _f(e,t,n){return xn&21?(ft(n,t)||(n=Ld(),ee.lanes|=n,vn|=n,e.baseState=!0),t):(e.baseState&&(e.baseState=!1,Oe=!0),e.memoizedState=n)}function Zh(e,t){var n=V;V=n!==0&&4>n?n:4,e(!0);var r=_l.transition;_l.transition={};try{e(!1),t()}finally{V=n,_l.transition=r}}function Ef(){return qe().memoizedState}function Xh(e,t,n){var r=Zt(e);if(n={lane:r,action:n,hasEagerState:!1,eagerState:null,next:null},jf(e))Tf(t,n);else if(n=uf(e,t,n,r),n!==null){var o=Te();ct(n,e,r,o),Lf(n,t,r)}}function Jh(e,t,n){var r=Zt(e),o={lane:r,action:n,hasEagerState:!1,eagerState:null,next:null};if(jf(e))Tf(t,o);else{var i=e.alternate;if(e.lanes===0&&(i===null||i.lanes===0)&&(i=t.lastRenderedReducer,i!==null))try{var l=t.lastRenderedState,a=i(l,n);if(o.hasEagerState=!0,o.eagerState=a,ft(a,l)){var s=t.interleaved;s===null?(o.next=o,ws(t)):(o.next=s.next,s.next=o),t.interleaved=o;return}}catch{}finally{}n=uf(e,t,o,r),n!==null&&(o=Te(),ct(n,e,r,o),Lf(n,t,r))}}function jf(e){var t=e.alternate;return e===ee||t!==null&&t===ee}function Tf(e,t){Ar=bi=!0;var n=e.pending;n===null?t.next=t:(t.next=n.next,n.next=t),e.pending=t}function Lf(e,t,n){if(n&4194240){var r=t.lanes;r&=e.pendingLanes,n|=r,t.lanes=n,ls(e,n)}}var Ci={readContext:Je,useCallback:ke,useContext:ke,useEffect:ke,useImperativeHandle:ke,useInsertionEffect:ke,useLayoutEffect:ke,useMemo:ke,useReducer:ke,useRef:ke,useState:ke,useDebugValue:ke,useDeferredValue:ke,useTransition:ke,useMutableSource:ke,useSyncExternalStore:ke,useId:ke,unstable_isNewReconciler:!1},qh={readContext:Je,useCallback:function(e,t){return gt().memoizedState=[e,t===void 0?null:t],e},useContext:Je,useEffect:Gu,useImperativeHandle:function(e,t,n){return n=n!=null?n.concat([e]):null,Zo(4194308,4,Sf.bind(null,t,e),n)},useLayoutEffect:function(e,t){return Zo(4194308,4,e,t)},useInsertionEffect:function(e,t){return Zo(4,2,e,t)},useMemo:function(e,t){var n=gt();return t=t===void 0?null:t,e=e(),n.memoizedState=[e,t],e},useReducer:function(e,t,n){var r=gt();return t=n!==void 0?n(t):t,r.memoizedState=r.baseState=t,e={pending:null,interleaved:null,lanes:0,dispatch:null,lastRenderedReducer:e,lastRenderedState:t},r.queue=e,e=e.dispatch=Xh.bind(null,ee,e),[r.memoizedState,e]},useRef:function(e){var t=gt();return e={current:e},t.memoizedState=e},useState:Vu,useDebugValue:Ts,useDeferredValue:function(e){return gt().memoizedState=e},useTransition:function(){var e=Vu(!1),t=e[0];return e=Zh.bind(null,e[1]),gt().memoizedState=e,[t,e]},useMutableSource:function(){},useSyncExternalStore:function(e,t,n){var r=ee,o=gt();if(X){if(n===void 0)throw Error(E(407));n=n()}else{if(n=t(),ge===null)throw Error(E(349));xn&30||hf(r,t,n)}o.memoizedState=n;var i={value:n,getSnapshot:t};return o.queue=i,Gu(gf.bind(null,r,i,e),[e]),r.flags|=2048,ao(9,mf.bind(null,r,i,n,t),void 0,null),n},useId:function(){var e=gt(),t=ge.identifierPrefix;if(X){var n=_t,r=Ct;n=(r&~(1<<32-ut(r)-1)).toString(32)+n,t=":"+t+"R"+n,n=io++,0<n&&(t+="H"+n.toString(32)),t+=":"}else n=Qh++,t=":"+t+"r"+n.toString(32)+":";return e.memoizedState=t},unstable_isNewReconciler:!1},em={readContext:Je,useCallback:bf,useContext:Je,useEffect:js,useImperativeHandle:$f,useInsertionEffect:wf,useLayoutEffect:kf,useMemo:Cf,useReducer:El,useRef:vf,useState:function(){return El(lo)},useDebugValue:Ts,useDeferredValue:function(e){var t=qe();return _f(t,fe.memoizedState,e)},useTransition:function(){var e=El(lo)[0],t=qe().memoizedState;return[e,t]},useMutableSource:ff,useSyncExternalStore:pf,useId:Ef,unstable_isNewReconciler:!1},tm={readContext:Je,useCallback:bf,useContext:Je,useEffect:js,useImperativeHandle:$f,useInsertionEffect:wf,useLayoutEffect:kf,useMemo:Cf,useReducer:jl,useRef:vf,useState:function(){return jl(lo)},useDebugValue:Ts,useDeferredValue:function(e){var t=qe();return fe===null?t.memoizedState=e:_f(t,fe.memoizedState,e)},useTransition:function(){var e=jl(lo)[0],t=qe().memoizedState;return[e,t]},useMutableSource:ff,useSyncExternalStore:pf,useId:Ef,unstable_isNewReconciler:!1};function ot(e,t){if(e&&e.defaultProps){t=te({},t),e=e.defaultProps;for(var n in e)t[n]===void 0&&(t[n]=e[n]);return t}return t}function ka(e,t,n,r){t=e.memoizedState,n=n(r,t),n=n==null?t:te({},t,n),e.memoizedState=n,e.lanes===0&&(e.updateQueue.baseState=n)}var Wi={isMounted:function(e){return(e=e._reactInternals)?$n(e)===e:!1},enqueueSetState:function(e,t,n){e=e._reactInternals;var r=Te(),o=Zt(e),i=Et(r,o);i.payload=t,n!=null&&(i.callback=n),t=Yt(e,i,o),t!==null&&(ct(t,e,o,r),Yo(t,e,o))},enqueueReplaceState:function(e,t,n){e=e._reactInternals;var r=Te(),o=Zt(e),i=Et(r,o);i.tag=1,i.payload=t,n!=null&&(i.callback=n),t=Yt(e,i,o),t!==null&&(ct(t,e,o,r),Yo(t,e,o))},enqueueForceUpdate:function(e,t){e=e._reactInternals;var n=Te(),r=Zt(e),o=Et(n,r);o.tag=2,t!=null&&(o.callback=t),t=Yt(e,o,r),t!==null&&(ct(t,e,r,n),Yo(t,e,r))}};function Ku(e,t,n,r,o,i,l){return e=e.stateNode,typeof e.shouldComponentUpdate=="function"?e.shouldComponentUpdate(r,i,l):t.prototype&&t.prototype.isPureReactComponent?!qr(n,r)||!qr(o,i):!0}function Pf(e,t,n){var r=!1,o=tn,i=t.contextType;return typeof i=="object"&&i!==null?i=Je(i):(o=Me(t)?gn:Ce.current,r=t.contextTypes,i=(r=r!=null)?Jn(e,o):tn),t=new t(n,i),e.memoizedState=t.state!==null&&t.state!==void 0?t.state:null,t.updater=Wi,e.stateNode=t,t._reactInternals=e,r&&(e=e.stateNode,e.__reactInternalMemoizedUnmaskedChildContext=o,e.__reactInternalMemoizedMaskedChildContext=i),t}function Yu(e,t,n,r){e=t.state,typeof t.componentWillReceiveProps=="function"&&t.componentWillReceiveProps(n,r),typeof t.UNSAFE_componentWillReceiveProps=="function"&&t.UNSAFE_componentWillReceiveProps(n,r),t.state!==e&&Wi.enqueueReplaceState(t,t.state,null)}function Sa(e,t,n,r){var o=e.stateNode;o.props=n,o.state=e.memoizedState,o.refs={},ks(e);var i=t.contextType;typeof i=="object"&&i!==null?o.context=Je(i):(i=Me(t)?gn:Ce.current,o.context=Jn(e,i)),o.state=e.memoizedState,i=t.getDerivedStateFromProps,typeof i=="function"&&(ka(e,t,i,n),o.state=e.memoizedState),typeof t.getDerivedStateFromProps=="function"||typeof o.getSnapshotBeforeUpdate=="function"||typeof o.UNSAFE_componentWillMount!="function"&&typeof o.componentWillMount!="function"||(t=o.state,typeof o.componentWillMount=="function"&&o.componentWillMount(),typeof o.UNSAFE_componentWillMount=="function"&&o.UNSAFE_componentWillMount(),t!==o.state&&Wi.enqueueReplaceState(o,o.state,null),Si(e,n,o,r),o.state=e.memoizedState),typeof o.componentDidMount=="function"&&(e.flags|=4194308)}function nr(e,t){try{var n="",r=t;do n+=T0(r),r=r.return;while(r);var o=n}catch(i){o=`
Error generating stack: `+i.message+`
`+i.stack}return{value:e,source:t,stack:o,digest:null}}function Tl(e,t,n){return{value:e,source:null,stack:n??null,digest:t??null}}function $a(e,t){try{console.error(t.value)}catch(n){setTimeout(function(){throw n})}}var nm=typeof WeakMap=="function"?WeakMap:Map;function Nf(e,t,n){n=Et(-1,n),n.tag=3,n.payload={element:null};var r=t.value;return n.callback=function(){Ei||(Ei=!0,Oa=r),$a(e,t)},n}function Of(e,t,n){n=Et(-1,n),n.tag=3;var r=e.type.getDerivedStateFromError;if(typeof r=="function"){var o=t.value;n.payload=function(){return r(o)},n.callback=function(){$a(e,t)}}var i=e.stateNode;return i!==null&&typeof i.componentDidCatch=="function"&&(n.callback=function(){$a(e,t),typeof r!="function"&&(Qt===null?Qt=new Set([this]):Qt.add(this));var l=t.stack;this.componentDidCatch(t.value,{componentStack:l!==null?l:""})}),n}function Qu(e,t,n){var r=e.pingCache;if(r===null){r=e.pingCache=new nm;var o=new Set;r.set(t,o)}else o=r.get(t),o===void 0&&(o=new Set,r.set(t,o));o.has(n)||(o.add(n),e=gm.bind(null,e,t,n),t.then(e,e))}function Zu(e){do{var t;if((t=e.tag===13)&&(t=e.memoizedState,t=t!==null?t.dehydrated!==null:!0),t)return e;e=e.return}while(e!==null);return null}function Xu(e,t,n,r,o){return e.mode&1?(e.flags|=65536,e.lanes=o,e):(e===t?e.flags|=65536:(e.flags|=128,n.flags|=131072,n.flags&=-52805,n.tag===1&&(n.alternate===null?n.tag=17:(t=Et(-1,1),t.tag=2,Yt(n,t,1))),n.lanes|=1),e)}var rm=Nt.ReactCurrentOwner,Oe=!1;function Ee(e,t,n,r){t.child=e===null?sf(t,null,n,r):er(t,e.child,n,r)}function Ju(e,t,n,r,o){n=n.render;var i=t.ref;return Yn(t,o),r=_s(e,t,n,r,i,o),n=Es(),e!==null&&!Oe?(t.updateQueue=e.updateQueue,t.flags&=-2053,e.lanes&=~o,Pt(e,t,o)):(X&&n&&hs(t),t.flags|=1,Ee(e,t,r,o),t.child)}function qu(e,t,n,r,o){if(e===null){var i=n.type;return typeof i=="function"&&!As(i)&&i.defaultProps===void 0&&n.compare===null&&n.defaultProps===void 0?(t.tag=15,t.type=i,Rf(e,t,i,r,o)):(e=ei(n.type,null,r,t,t.mode,o),e.ref=t.ref,e.return=t,t.child=e)}if(i=e.child,!(e.lanes&o)){var l=i.memoizedProps;if(n=n.compare,n=n!==null?n:qr,n(l,r)&&e.ref===t.ref)return Pt(e,t,o)}return t.flags|=1,e=Xt(i,r),e.ref=t.ref,e.return=t,t.child=e}function Rf(e,t,n,r,o){if(e!==null){var i=e.memoizedProps;if(qr(i,r)&&e.ref===t.ref)if(Oe=!1,t.pendingProps=r=i,(e.lanes&o)!==0)e.flags&131072&&(Oe=!0);else return t.lanes=e.lanes,Pt(e,t,o)}return ba(e,t,n,r,o)}function Mf(e,t,n){var r=t.pendingProps,o=r.children,i=e!==null?e.memoizedState:null;if(r.mode==="hidden")if(!(t.mode&1))t.memoizedState={baseLanes:0,cachePool:null,transitions:null},K(Un,Be),Be|=n;else{if(!(n&1073741824))return e=i!==null?i.baseLanes|n:n,t.lanes=t.childLanes=1073741824,t.memoizedState={baseLanes:e,cachePool:null,transitions:null},t.updateQueue=null,K(Un,Be),Be|=e,null;t.memoizedState={baseLanes:0,cachePool:null,transitions:null},r=i!==null?i.baseLanes:n,K(Un,Be),Be|=r}else i!==null?(r=i.baseLanes|n,t.memoizedState=null):r=n,K(Un,Be),Be|=r;return Ee(e,t,o,n),t.child}function zf(e,t){var n=t.ref;(e===null&&n!==null||e!==null&&e.ref!==n)&&(t.flags|=512,t.flags|=2097152)}function ba(e,t,n,r,o){var i=Me(n)?gn:Ce.current;return i=Jn(t,i),Yn(t,o),n=_s(e,t,n,r,i,o),r=Es(),e!==null&&!Oe?(t.updateQueue=e.updateQueue,t.flags&=-2053,e.lanes&=~o,Pt(e,t,o)):(X&&r&&hs(t),t.flags|=1,Ee(e,t,n,o),t.child)}function ec(e,t,n,r,o){if(Me(n)){var i=!0;yi(t)}else i=!1;if(Yn(t,o),t.stateNode===null)Xo(e,t),Pf(t,n,r),Sa(t,n,r,o),r=!0;else if(e===null){var l=t.stateNode,a=t.memoizedProps;l.props=a;var s=l.context,c=n.contextType;typeof c=="object"&&c!==null?c=Je(c):(c=Me(n)?gn:Ce.current,c=Jn(t,c));var m=n.getDerivedStateFromProps,h=typeof m=="function"||typeof l.getSnapshotBeforeUpdate=="function";h||typeof l.UNSAFE_componentWillReceiveProps!="function"&&typeof l.componentWillReceiveProps!="function"||(a!==r||s!==c)&&Yu(t,l,r,c),At=!1;var f=t.memoizedState;l.state=f,Si(t,r,l,o),s=t.memoizedState,a!==r||f!==s||Re.current||At?(typeof m=="function"&&(ka(t,n,m,r),s=t.memoizedState),(a=At||Ku(t,n,a,r,f,s,c))?(h||typeof l.UNSAFE_componentWillMount!="function"&&typeof l.componentWillMount!="function"||(typeof l.componentWillMount=="function"&&l.componentWillMount(),typeof l.UNSAFE_componentWillMount=="function"&&l.UNSAFE_componentWillMount()),typeof l.componentDidMount=="function"&&(t.flags|=4194308)):(typeof l.componentDidMount=="function"&&(t.flags|=4194308),t.memoizedProps=r,t.memoizedState=s),l.props=r,l.state=s,l.context=c,r=a):(typeof l.componentDidMount=="function"&&(t.flags|=4194308),r=!1)}else{l=t.stateNode,cf(e,t),a=t.memoizedProps,c=t.type===t.elementType?a:ot(t.type,a),l.props=c,h=t.pendingProps,f=l.context,s=n.contextType,typeof s=="object"&&s!==null?s=Je(s):(s=Me(n)?gn:Ce.current,s=Jn(t,s));var w=n.getDerivedStateFromProps;(m=typeof w=="function"||typeof l.getSnapshotBeforeUpdate=="function")||typeof l.UNSAFE_componentWillReceiveProps!="function"&&typeof l.componentWillReceiveProps!="function"||(a!==h||f!==s)&&Yu(t,l,r,s),At=!1,f=t.memoizedState,l.state=f,Si(t,r,l,o);var v=t.memoizedState;a!==h||f!==v||Re.current||At?(typeof w=="function"&&(ka(t,n,w,r),v=t.memoizedState),(c=At||Ku(t,n,c,r,f,v,s)||!1)?(m||typeof l.UNSAFE_componentWillUpdate!="function"&&typeof l.componentWillUpdate!="function"||(typeof l.componentWillUpdate=="function"&&l.componentWillUpdate(r,v,s),typeof l.UNSAFE_componentWillUpdate=="function"&&l.UNSAFE_componentWillUpdate(r,v,s)),typeof l.componentDidUpdate=="function"&&(t.flags|=4),typeof l.getSnapshotBeforeUpdate=="function"&&(t.flags|=1024)):(typeof l.componentDidUpdate!="function"||a===e.memoizedProps&&f===e.memoizedState||(t.flags|=4),typeof l.getSnapshotBeforeUpdate!="function"||a===e.memoizedProps&&f===e.memoizedState||(t.flags|=1024),t.memoizedProps=r,t.memoizedState=v),l.props=r,l.state=v,l.context=s,r=c):(typeof l.componentDidUpdate!="function"||a===e.memoizedProps&&f===e.memoizedState||(t.flags|=4),typeof l.getSnapshotBeforeUpdate!="function"||a===e.memoizedProps&&f===e.memoizedState||(t.flags|=1024),r=!1)}return Ca(e,t,n,r,i,o)}function Ca(e,t,n,r,o,i){zf(e,t);var l=(t.flags&128)!==0;if(!r&&!l)return o&&Bu(t,n,!1),Pt(e,t,i);r=t.stateNode,rm.current=t;var a=l&&typeof n.getDerivedStateFromError!="function"?null:r.render();return t.flags|=1,e!==null&&l?(t.child=er(t,e.child,null,i),t.child=er(t,null,a,i)):Ee(e,t,a,i),t.memoizedState=r.state,o&&Bu(t,n,!0),t.child}function Af(e){var t=e.stateNode;t.pendingContext?Iu(e,t.pendingContext,t.pendingContext!==t.context):t.context&&Iu(e,t.context,!1),Ss(e,t.containerInfo)}function tc(e,t,n,r,o){return qn(),gs(o),t.flags|=256,Ee(e,t,n,r),t.child}var _a={dehydrated:null,treeContext:null,retryLane:0};function Ea(e){return{baseLanes:e,cachePool:null,transitions:null}}function If(e,t,n){var r=t.pendingProps,o=J.current,i=!1,l=(t.flags&128)!==0,a;if((a=l)||(a=e!==null&&e.memoizedState===null?!1:(o&2)!==0),a?(i=!0,t.flags&=-129):(e===null||e.memoizedState!==null)&&(o|=1),K(J,o&1),e===null)return va(t),e=t.memoizedState,e!==null&&(e=e.dehydrated,e!==null)?(t.mode&1?e.data==="$!"?t.lanes=8:t.lanes=1073741824:t.lanes=1,null):(l=r.children,e=r.fallback,i?(r=t.mode,i=t.child,l={mode:"hidden",children:l},!(r&1)&&i!==null?(i.childLanes=0,i.pendingProps=l):i=Ki(l,r,0,null),e=pn(e,r,n,null),i.return=t,e.return=t,i.sibling=e,t.child=i,t.child.memoizedState=Ea(n),t.memoizedState=_a,e):Ls(t,l));if(o=e.memoizedState,o!==null&&(a=o.dehydrated,a!==null))return om(e,t,l,r,a,o,n);if(i){i=r.fallback,l=t.mode,o=e.child,a=o.sibling;var s={mode:"hidden",children:r.children};return!(l&1)&&t.child!==o?(r=t.child,r.childLanes=0,r.pendingProps=s,t.deletions=null):(r=Xt(o,s),r.subtreeFlags=o.subtreeFlags&14680064),a!==null?i=Xt(a,i):(i=pn(i,l,n,null),i.flags|=2),i.return=t,r.return=t,r.sibling=i,t.child=r,r=i,i=t.child,l=e.child.memoizedState,l=l===null?Ea(n):{baseLanes:l.baseLanes|n,cachePool:null,transitions:l.transitions},i.memoizedState=l,i.childLanes=e.childLanes&~n,t.memoizedState=_a,r}return i=e.child,e=i.sibling,r=Xt(i,{mode:"visible",children:r.children}),!(t.mode&1)&&(r.lanes=n),r.return=t,r.sibling=null,e!==null&&(n=t.deletions,n===null?(t.deletions=[e],t.flags|=16):n.push(e)),t.child=r,t.memoizedState=null,r}function Ls(e,t){return t=Ki({mode:"visible",children:t},e.mode,0,null),t.return=e,e.child=t}function Io(e,t,n,r){return r!==null&&gs(r),er(t,e.child,null,n),e=Ls(t,t.pendingProps.children),e.flags|=2,t.memoizedState=null,e}function om(e,t,n,r,o,i,l){if(n)return t.flags&256?(t.flags&=-257,r=Tl(Error(E(422))),Io(e,t,l,r)):t.memoizedState!==null?(t.child=e.child,t.flags|=128,null):(i=r.fallback,o=t.mode,r=Ki({mode:"visible",children:r.children},o,0,null),i=pn(i,o,l,null),i.flags|=2,r.return=t,i.return=t,r.sibling=i,t.child=r,t.mode&1&&er(t,e.child,null,l),t.child.memoizedState=Ea(l),t.memoizedState=_a,i);if(!(t.mode&1))return Io(e,t,l,null);if(o.data==="$!"){if(r=o.nextSibling&&o.nextSibling.dataset,r)var a=r.dgst;return r=a,i=Error(E(419)),r=Tl(i,r,void 0),Io(e,t,l,r)}if(a=(l&e.childLanes)!==0,Oe||a){if(r=ge,r!==null){switch(l&-l){case 4:o=2;break;case 16:o=8;break;case 64:case 128:case 256:case 512:case 1024:case 2048:case 4096:case 8192:case 16384:case 32768:case 65536:case 131072:case 262144:case 524288:case 1048576:case 2097152:case 4194304:case 8388608:case 16777216:case 33554432:case 67108864:o=32;break;case 536870912:o=268435456;break;default:o=0}o=o&(r.suspendedLanes|l)?0:o,o!==0&&o!==i.retryLane&&(i.retryLane=o,Lt(e,o),ct(r,e,o,-1))}return zs(),r=Tl(Error(E(421))),Io(e,t,l,r)}return o.data==="$?"?(t.flags|=128,t.child=e.child,t=ym.bind(null,e),o._reactRetry=t,null):(e=i.treeContext,De=Kt(o.nextSibling),He=t,X=!0,at=null,e!==null&&(Ye[Qe++]=Ct,Ye[Qe++]=_t,Ye[Qe++]=yn,Ct=e.id,_t=e.overflow,yn=t),t=Ls(t,r.children),t.flags|=4096,t)}function nc(e,t,n){e.lanes|=t;var r=e.alternate;r!==null&&(r.lanes|=t),wa(e.return,t,n)}function Ll(e,t,n,r,o){var i=e.memoizedState;i===null?e.memoizedState={isBackwards:t,rendering:null,renderingStartTime:0,last:r,tail:n,tailMode:o}:(i.isBackwards=t,i.rendering=null,i.renderingStartTime=0,i.last=r,i.tail=n,i.tailMode=o)}function Bf(e,t,n){var r=t.pendingProps,o=r.revealOrder,i=r.tail;if(Ee(e,t,r.children,n),r=J.current,r&2)r=r&1|2,t.flags|=128;else{if(e!==null&&e.flags&128)e:for(e=t.child;e!==null;){if(e.tag===13)e.memoizedState!==null&&nc(e,n,t);else if(e.tag===19)nc(e,n,t);else if(e.child!==null){e.child.return=e,e=e.child;continue}if(e===t)break e;for(;e.sibling===null;){if(e.return===null||e.return===t)break e;e=e.return}e.sibling.return=e.return,e=e.sibling}r&=1}if(K(J,r),!(t.mode&1))t.memoizedState=null;else switch(o){case"forwards":for(n=t.child,o=null;n!==null;)e=n.alternate,e!==null&&$i(e)===null&&(o=n),n=n.sibling;n=o,n===null?(o=t.child,t.child=null):(o=n.sibling,n.sibling=null),Ll(t,!1,o,n,i);break;case"backwards":for(n=null,o=t.child,t.child=null;o!==null;){if(e=o.alternate,e!==null&&$i(e)===null){t.child=o;break}e=o.sibling,o.sibling=n,n=o,o=e}Ll(t,!0,n,null,i);break;case"together":Ll(t,!1,null,null,void 0);break;default:t.memoizedState=null}return t.child}function Xo(e,t){!(t.mode&1)&&e!==null&&(e.alternate=null,t.alternate=null,t.flags|=2)}function Pt(e,t,n){if(e!==null&&(t.dependencies=e.dependencies),vn|=t.lanes,!(n&t.childLanes))return null;if(e!==null&&t.child!==e.child)throw Error(E(153));if(t.child!==null){for(e=t.child,n=Xt(e,e.pendingProps),t.child=n,n.return=t;e.sibling!==null;)e=e.sibling,n=n.sibling=Xt(e,e.pendingProps),n.return=t;n.sibling=null}return t.child}function im(e,t,n){switch(t.tag){case 3:Af(t),qn();break;case 5:df(t);break;case 1:Me(t.type)&&yi(t);break;case 4:Ss(t,t.stateNode.containerInfo);break;case 10:var r=t.type._context,o=t.memoizedProps.value;K(wi,r._currentValue),r._currentValue=o;break;case 13:if(r=t.memoizedState,r!==null)return r.dehydrated!==null?(K(J,J.current&1),t.flags|=128,null):n&t.child.childLanes?If(e,t,n):(K(J,J.current&1),e=Pt(e,t,n),e!==null?e.sibling:null);K(J,J.current&1);break;case 19:if(r=(n&t.childLanes)!==0,e.flags&128){if(r)return Bf(e,t,n);t.flags|=128}if(o=t.memoizedState,o!==null&&(o.rendering=null,o.tail=null,o.lastEffect=null),K(J,J.current),r)break;return null;case 22:case 23:return t.lanes=0,Mf(e,t,n)}return Pt(e,t,n)}var Ff,ja,Df,Hf;Ff=function(e,t){for(var n=t.child;n!==null;){if(n.tag===5||n.tag===6)e.appendChild(n.stateNode);else if(n.tag!==4&&n.child!==null){n.child.return=n,n=n.child;continue}if(n===t)break;for(;n.sibling===null;){if(n.return===null||n.return===t)return;n=n.return}n.sibling.return=n.return,n=n.sibling}};ja=function(){};Df=function(e,t,n,r){var o=e.memoizedProps;if(o!==r){e=t.stateNode,dn(wt.current);var i=null;switch(n){case"input":o=Zl(e,o),r=Zl(e,r),i=[];break;case"select":o=te({},o,{value:void 0}),r=te({},r,{value:void 0}),i=[];break;case"textarea":o=ql(e,o),r=ql(e,r),i=[];break;default:typeof o.onClick!="function"&&typeof r.onClick=="function"&&(e.onclick=mi)}ta(n,r);var l;n=null;for(c in o)if(!r.hasOwnProperty(c)&&o.hasOwnProperty(c)&&o[c]!=null)if(c==="style"){var a=o[c];for(l in a)a.hasOwnProperty(l)&&(n||(n={}),n[l]="")}else c!=="dangerouslySetInnerHTML"&&c!=="children"&&c!=="suppressContentEditableWarning"&&c!=="suppressHydrationWarning"&&c!=="autoFocus"&&(Gr.hasOwnProperty(c)?i||(i=[]):(i=i||[]).push(c,null));for(c in r){var s=r[c];if(a=o?.[c],r.hasOwnProperty(c)&&s!==a&&(s!=null||a!=null))if(c==="style")if(a){for(l in a)!a.hasOwnProperty(l)||s&&s.hasOwnProperty(l)||(n||(n={}),n[l]="");for(l in s)s.hasOwnProperty(l)&&a[l]!==s[l]&&(n||(n={}),n[l]=s[l])}else n||(i||(i=[]),i.push(c,n)),n=s;else c==="dangerouslySetInnerHTML"?(s=s?s.__html:void 0,a=a?a.__html:void 0,s!=null&&a!==s&&(i=i||[]).push(c,s)):c==="children"?typeof s!="string"&&typeof s!="number"||(i=i||[]).push(c,""+s):c!=="suppressContentEditableWarning"&&c!=="suppressHydrationWarning"&&(Gr.hasOwnProperty(c)?(s!=null&&c==="onScroll"&&Y("scroll",e),i||a===s||(i=[])):(i=i||[]).push(c,s))}n&&(i=i||[]).push("style",n);var c=i;(t.updateQueue=c)&&(t.flags|=4)}};Hf=function(e,t,n,r){n!==r&&(t.flags|=4)};function kr(e,t){if(!X)switch(e.tailMode){case"hidden":t=e.tail;for(var n=null;t!==null;)t.alternate!==null&&(n=t),t=t.sibling;n===null?e.tail=null:n.sibling=null;break;case"collapsed":n=e.tail;for(var r=null;n!==null;)n.alternate!==null&&(r=n),n=n.sibling;r===null?t||e.tail===null?e.tail=null:e.tail.sibling=null:r.sibling=null}}function Se(e){var t=e.alternate!==null&&e.alternate.child===e.child,n=0,r=0;if(t)for(var o=e.child;o!==null;)n|=o.lanes|o.childLanes,r|=o.subtreeFlags&14680064,r|=o.flags&14680064,o.return=e,o=o.sibling;else for(o=e.child;o!==null;)n|=o.lanes|o.childLanes,r|=o.subtreeFlags,r|=o.flags,o.return=e,o=o.sibling;return e.subtreeFlags|=r,e.childLanes=n,t}function lm(e,t,n){var r=t.pendingProps;switch(ms(t),t.tag){case 2:case 16:case 15:case 0:case 11:case 7:case 8:case 12:case 9:case 14:return Se(t),null;case 1:return Me(t.type)&&gi(),Se(t),null;case 3:return r=t.stateNode,tr(),Z(Re),Z(Ce),bs(),r.pendingContext&&(r.context=r.pendingContext,r.pendingContext=null),(e===null||e.child===null)&&(zo(t)?t.flags|=4:e===null||e.memoizedState.isDehydrated&&!(t.flags&256)||(t.flags|=1024,at!==null&&(za(at),at=null))),ja(e,t),Se(t),null;case 5:$s(t);var o=dn(oo.current);if(n=t.type,e!==null&&t.stateNode!=null)Df(e,t,n,r,o),e.ref!==t.ref&&(t.flags|=512,t.flags|=2097152);else{if(!r){if(t.stateNode===null)throw Error(E(166));return Se(t),null}if(e=dn(wt.current),zo(t)){r=t.stateNode,n=t.type;var i=t.memoizedProps;switch(r[xt]=t,r[no]=i,e=(t.mode&1)!==0,n){case"dialog":Y("cancel",r),Y("close",r);break;case"iframe":case"object":case"embed":Y("load",r);break;case"video":case"audio":for(o=0;o<jr.length;o++)Y(jr[o],r);break;case"source":Y("error",r);break;case"img":case"image":case"link":Y("error",r),Y("load",r);break;case"details":Y("toggle",r);break;case"input":du(r,i),Y("invalid",r);break;case"select":r._wrapperState={wasMultiple:!!i.multiple},Y("invalid",r);break;case"textarea":pu(r,i),Y("invalid",r)}ta(n,i),o=null;for(var l in i)if(i.hasOwnProperty(l)){var a=i[l];l==="children"?typeof a=="string"?r.textContent!==a&&(i.suppressHydrationWarning!==!0&&Mo(r.textContent,a,e),o=["children",a]):typeof a=="number"&&r.textContent!==""+a&&(i.suppressHydrationWarning!==!0&&Mo(r.textContent,a,e),o=["children",""+a]):Gr.hasOwnProperty(l)&&a!=null&&l==="onScroll"&&Y("scroll",r)}switch(n){case"input":Eo(r),fu(r,i,!0);break;case"textarea":Eo(r),hu(r);break;case"select":case"option":break;default:typeof i.onClick=="function"&&(r.onclick=mi)}r=o,t.updateQueue=r,r!==null&&(t.flags|=4)}else{l=o.nodeType===9?o:o.ownerDocument,e==="http://www.w3.org/1999/xhtml"&&(e=md(n)),e==="http://www.w3.org/1999/xhtml"?n==="script"?(e=l.createElement("div"),e.innerHTML="<script><\/script>",e=e.removeChild(e.firstChild)):typeof r.is=="string"?e=l.createElement(n,{is:r.is}):(e=l.createElement(n),n==="select"&&(l=e,r.multiple?l.multiple=!0:r.size&&(l.size=r.size))):e=l.createElementNS(e,n),e[xt]=t,e[no]=r,Ff(e,t,!1,!1),t.stateNode=e;e:{switch(l=na(n,r),n){case"dialog":Y("cancel",e),Y("close",e),o=r;break;case"iframe":case"object":case"embed":Y("load",e),o=r;break;case"video":case"audio":for(o=0;o<jr.length;o++)Y(jr[o],e);o=r;break;case"source":Y("error",e),o=r;break;case"img":case"image":case"link":Y("error",e),Y("load",e),o=r;break;case"details":Y("toggle",e),o=r;break;case"input":du(e,r),o=Zl(e,r),Y("invalid",e);break;case"option":o=r;break;case"select":e._wrapperState={wasMultiple:!!r.multiple},o=te({},r,{value:void 0}),Y("invalid",e);break;case"textarea":pu(e,r),o=ql(e,r),Y("invalid",e);break;default:o=r}ta(n,o),a=o;for(i in a)if(a.hasOwnProperty(i)){var s=a[i];i==="style"?xd(e,s):i==="dangerouslySetInnerHTML"?(s=s?s.__html:void 0,s!=null&&gd(e,s)):i==="children"?typeof s=="string"?(n!=="textarea"||s!=="")&&Kr(e,s):typeof s=="number"&&Kr(e,""+s):i!=="suppressContentEditableWarning"&&i!=="suppressHydrationWarning"&&i!=="autoFocus"&&(Gr.hasOwnProperty(i)?s!=null&&i==="onScroll"&&Y("scroll",e):s!=null&&es(e,i,s,l))}switch(n){case"input":Eo(e),fu(e,r,!1);break;case"textarea":Eo(e),hu(e);break;case"option":r.value!=null&&e.setAttribute("value",""+en(r.value));break;case"select":e.multiple=!!r.multiple,i=r.value,i!=null?Wn(e,!!r.multiple,i,!1):r.defaultValue!=null&&Wn(e,!!r.multiple,r.defaultValue,!0);break;default:typeof o.onClick=="function"&&(e.onclick=mi)}switch(n){case"button":case"input":case"select":case"textarea":r=!!r.autoFocus;break e;case"img":r=!0;break e;default:r=!1}}r&&(t.flags|=4)}t.ref!==null&&(t.flags|=512,t.flags|=2097152)}return Se(t),null;case 6:if(e&&t.stateNode!=null)Hf(e,t,e.memoizedProps,r);else{if(typeof r!="string"&&t.stateNode===null)throw Error(E(166));if(n=dn(oo.current),dn(wt.current),zo(t)){if(r=t.stateNode,n=t.memoizedProps,r[xt]=t,(i=r.nodeValue!==n)&&(e=He,e!==null))switch(e.tag){case 3:Mo(r.nodeValue,n,(e.mode&1)!==0);break;case 5:e.memoizedProps.suppressHydrationWarning!==!0&&Mo(r.nodeValue,n,(e.mode&1)!==0)}i&&(t.flags|=4)}else r=(n.nodeType===9?n:n.ownerDocument).createTextNode(r),r[xt]=t,t.stateNode=r}return Se(t),null;case 13:if(Z(J),r=t.memoizedState,e===null||e.memoizedState!==null&&e.memoizedState.dehydrated!==null){if(X&&De!==null&&t.mode&1&&!(t.flags&128))lf(),qn(),t.flags|=98560,i=!1;else if(i=zo(t),r!==null&&r.dehydrated!==null){if(e===null){if(!i)throw Error(E(318));if(i=t.memoizedState,i=i!==null?i.dehydrated:null,!i)throw Error(E(317));i[xt]=t}else qn(),!(t.flags&128)&&(t.memoizedState=null),t.flags|=4;Se(t),i=!1}else at!==null&&(za(at),at=null),i=!0;if(!i)return t.flags&65536?t:null}return t.flags&128?(t.lanes=n,t):(r=r!==null,r!==(e!==null&&e.memoizedState!==null)&&r&&(t.child.flags|=8192,t.mode&1&&(e===null||J.current&1?he===0&&(he=3):zs())),t.updateQueue!==null&&(t.flags|=4),Se(t),null);case 4:return tr(),ja(e,t),e===null&&eo(t.stateNode.containerInfo),Se(t),null;case 10:return vs(t.type._context),Se(t),null;case 17:return Me(t.type)&&gi(),Se(t),null;case 19:if(Z(J),i=t.memoizedState,i===null)return Se(t),null;if(r=(t.flags&128)!==0,l=i.rendering,l===null)if(r)kr(i,!1);else{if(he!==0||e!==null&&e.flags&128)for(e=t.child;e!==null;){if(l=$i(e),l!==null){for(t.flags|=128,kr(i,!1),r=l.updateQueue,r!==null&&(t.updateQueue=r,t.flags|=4),t.subtreeFlags=0,r=n,n=t.child;n!==null;)i=n,e=r,i.flags&=14680066,l=i.alternate,l===null?(i.childLanes=0,i.lanes=e,i.child=null,i.subtreeFlags=0,i.memoizedProps=null,i.memoizedState=null,i.updateQueue=null,i.dependencies=null,i.stateNode=null):(i.childLanes=l.childLanes,i.lanes=l.lanes,i.child=l.child,i.subtreeFlags=0,i.deletions=null,i.memoizedProps=l.memoizedProps,i.memoizedState=l.memoizedState,i.updateQueue=l.updateQueue,i.type=l.type,e=l.dependencies,i.dependencies=e===null?null:{lanes:e.lanes,firstContext:e.firstContext}),n=n.sibling;return K(J,J.current&1|2),t.child}e=e.sibling}i.tail!==null&&oe()>rr&&(t.flags|=128,r=!0,kr(i,!1),t.lanes=4194304)}else{if(!r)if(e=$i(l),e!==null){if(t.flags|=128,r=!0,n=e.updateQueue,n!==null&&(t.updateQueue=n,t.flags|=4),kr(i,!0),i.tail===null&&i.tailMode==="hidden"&&!l.alternate&&!X)return Se(t),null}else 2*oe()-i.renderingStartTime>rr&&n!==1073741824&&(t.flags|=128,r=!0,kr(i,!1),t.lanes=4194304);i.isBackwards?(l.sibling=t.child,t.child=l):(n=i.last,n!==null?n.sibling=l:t.child=l,i.last=l)}return i.tail!==null?(t=i.tail,i.rendering=t,i.tail=t.sibling,i.renderingStartTime=oe(),t.sibling=null,n=J.current,K(J,r?n&1|2:n&1),t):(Se(t),null);case 22:case 23:return Ms(),r=t.memoizedState!==null,e!==null&&e.memoizedState!==null!==r&&(t.flags|=8192),r&&t.mode&1?Be&1073741824&&(Se(t),t.subtreeFlags&6&&(t.flags|=8192)):Se(t),null;case 24:return null;case 25:return null}throw Error(E(156,t.tag))}function am(e,t){switch(ms(t),t.tag){case 1:return Me(t.type)&&gi(),e=t.flags,e&65536?(t.flags=e&-65537|128,t):null;case 3:return tr(),Z(Re),Z(Ce),bs(),e=t.flags,e&65536&&!(e&128)?(t.flags=e&-65537|128,t):null;case 5:return $s(t),null;case 13:if(Z(J),e=t.memoizedState,e!==null&&e.dehydrated!==null){if(t.alternate===null)throw Error(E(340));qn()}return e=t.flags,e&65536?(t.flags=e&-65537|128,t):null;case 19:return Z(J),null;case 4:return tr(),null;case 10:return vs(t.type._context),null;case 22:case 23:return Ms(),null;case 24:return null;default:return null}}var Bo=!1,be=!1,sm=typeof WeakSet=="function"?WeakSet:Set,L=null;function Hn(e,t){var n=e.ref;if(n!==null)if(typeof n=="function")try{n(null)}catch(r){re(e,t,r)}else n.current=null}function Ta(e,t,n){try{n()}catch(r){re(e,t,r)}}var rc=!1;function um(e,t){if(fa=fi,e=Gd(),ps(e)){if("selectionStart"in e)var n={start:e.selectionStart,end:e.selectionEnd};else e:{n=(n=e.ownerDocument)&&n.defaultView||window;var r=n.getSelection&&n.getSelection();if(r&&r.rangeCount!==0){n=r.anchorNode;var o=r.anchorOffset,i=r.focusNode;r=r.focusOffset;try{n.nodeType,i.nodeType}catch{n=null;break e}var l=0,a=-1,s=-1,c=0,m=0,h=e,f=null;t:for(;;){for(var w;h!==n||o!==0&&h.nodeType!==3||(a=l+o),h!==i||r!==0&&h.nodeType!==3||(s=l+r),h.nodeType===3&&(l+=h.nodeValue.length),(w=h.firstChild)!==null;)f=h,h=w;for(;;){if(h===e)break t;if(f===n&&++c===o&&(a=l),f===i&&++m===r&&(s=l),(w=h.nextSibling)!==null)break;h=f,f=h.parentNode}h=w}n=a===-1||s===-1?null:{start:a,end:s}}else n=null}n=n||{start:0,end:0}}else n=null;for(pa={focusedElem:e,selectionRange:n},fi=!1,L=t;L!==null;)if(t=L,e=t.child,(t.subtreeFlags&1028)!==0&&e!==null)e.return=t,L=e;else for(;L!==null;){t=L;try{var v=t.alternate;if(t.flags&1024)switch(t.tag){case 0:case 11:case 15:break;case 1:if(v!==null){var k=v.memoizedProps,_=v.memoizedState,p=t.stateNode,d=p.getSnapshotBeforeUpdate(t.elementType===t.type?k:ot(t.type,k),_);p.__reactInternalSnapshotBeforeUpdate=d}break;case 3:var g=t.stateNode.containerInfo;g.nodeType===1?g.textContent="":g.nodeType===9&&g.documentElement&&g.removeChild(g.documentElement);break;case 5:case 6:case 4:case 17:break;default:throw Error(E(163))}}catch(S){re(t,t.return,S)}if(e=t.sibling,e!==null){e.return=t.return,L=e;break}L=t.return}return v=rc,rc=!1,v}function Ir(e,t,n){var r=t.updateQueue;if(r=r!==null?r.lastEffect:null,r!==null){var o=r=r.next;do{if((o.tag&e)===e){var i=o.destroy;o.destroy=void 0,i!==void 0&&Ta(t,n,i)}o=o.next}while(o!==r)}}function Vi(e,t){if(t=t.updateQueue,t=t!==null?t.lastEffect:null,t!==null){var n=t=t.next;do{if((n.tag&e)===e){var r=n.create;n.destroy=r()}n=n.next}while(n!==t)}}function La(e){var t=e.ref;if(t!==null){var n=e.stateNode;switch(e.tag){case 5:e=n;break;default:e=n}typeof t=="function"?t(e):t.current=e}}function Uf(e){var t=e.alternate;t!==null&&(e.alternate=null,Uf(t)),e.child=null,e.deletions=null,e.sibling=null,e.tag===5&&(t=e.stateNode,t!==null&&(delete t[xt],delete t[no],delete t[ga],delete t[Vh],delete t[Gh])),e.stateNode=null,e.return=null,e.dependencies=null,e.memoizedProps=null,e.memoizedState=null,e.pendingProps=null,e.stateNode=null,e.updateQueue=null}function Wf(e){return e.tag===5||e.tag===3||e.tag===4}function oc(e){e:for(;;){for(;e.sibling===null;){if(e.return===null||Wf(e.return))return null;e=e.return}for(e.sibling.return=e.return,e=e.sibling;e.tag!==5&&e.tag!==6&&e.tag!==18;){if(e.flags&2||e.child===null||e.tag===4)continue e;e.child.return=e,e=e.child}if(!(e.flags&2))return e.stateNode}}function Pa(e,t,n){var r=e.tag;if(r===5||r===6)e=e.stateNode,t?n.nodeType===8?n.parentNode.insertBefore(e,t):n.insertBefore(e,t):(n.nodeType===8?(t=n.parentNode,t.insertBefore(e,n)):(t=n,t.appendChild(e)),n=n._reactRootContainer,n!=null||t.onclick!==null||(t.onclick=mi));else if(r!==4&&(e=e.child,e!==null))for(Pa(e,t,n),e=e.sibling;e!==null;)Pa(e,t,n),e=e.sibling}function Na(e,t,n){var r=e.tag;if(r===5||r===6)e=e.stateNode,t?n.insertBefore(e,t):n.appendChild(e);else if(r!==4&&(e=e.child,e!==null))for(Na(e,t,n),e=e.sibling;e!==null;)Na(e,t,n),e=e.sibling}var ye=null,it=!1;function Rt(e,t,n){for(n=n.child;n!==null;)Vf(e,t,n),n=n.sibling}function Vf(e,t,n){if(vt&&typeof vt.onCommitFiberUnmount=="function")try{vt.onCommitFiberUnmount(Ai,n)}catch{}switch(n.tag){case 5:be||Hn(n,t);case 6:var r=ye,o=it;ye=null,Rt(e,t,n),ye=r,it=o,ye!==null&&(it?(e=ye,n=n.stateNode,e.nodeType===8?e.parentNode.removeChild(n):e.removeChild(n)):ye.removeChild(n.stateNode));break;case 18:ye!==null&&(it?(e=ye,n=n.stateNode,e.nodeType===8?$l(e.parentNode,n):e.nodeType===1&&$l(e,n),Xr(e)):$l(ye,n.stateNode));break;case 4:r=ye,o=it,ye=n.stateNode.containerInfo,it=!0,Rt(e,t,n),ye=r,it=o;break;case 0:case 11:case 14:case 15:if(!be&&(r=n.updateQueue,r!==null&&(r=r.lastEffect,r!==null))){o=r=r.next;do{var i=o,l=i.destroy;i=i.tag,l!==void 0&&(i&2||i&4)&&Ta(n,t,l),o=o.next}while(o!==r)}Rt(e,t,n);break;case 1:if(!be&&(Hn(n,t),r=n.stateNode,typeof r.componentWillUnmount=="function"))try{r.props=n.memoizedProps,r.state=n.memoizedState,r.componentWillUnmount()}catch(a){re(n,t,a)}Rt(e,t,n);break;case 21:Rt(e,t,n);break;case 22:n.mode&1?(be=(r=be)||n.memoizedState!==null,Rt(e,t,n),be=r):Rt(e,t,n);break;default:Rt(e,t,n)}}function ic(e){var t=e.updateQueue;if(t!==null){e.updateQueue=null;var n=e.stateNode;n===null&&(n=e.stateNode=new sm),t.forEach(function(r){var o=xm.bind(null,e,r);n.has(r)||(n.add(r),r.then(o,o))})}}function nt(e,t){var n=t.deletions;if(n!==null)for(var r=0;r<n.length;r++){var o=n[r];try{var i=e,l=t,a=l;e:for(;a!==null;){switch(a.tag){case 5:ye=a.stateNode,it=!1;break e;case 3:ye=a.stateNode.containerInfo,it=!0;break e;case 4:ye=a.stateNode.containerInfo,it=!0;break e}a=a.return}if(ye===null)throw Error(E(160));Vf(i,l,o),ye=null,it=!1;var s=o.alternate;s!==null&&(s.return=null),o.return=null}catch(c){re(o,t,c)}}if(t.subtreeFlags&12854)for(t=t.child;t!==null;)Gf(t,e),t=t.sibling}function Gf(e,t){var n=e.alternate,r=e.flags;switch(e.tag){case 0:case 11:case 14:case 15:if(nt(t,e),mt(e),r&4){try{Ir(3,e,e.return),Vi(3,e)}catch(k){re(e,e.return,k)}try{Ir(5,e,e.return)}catch(k){re(e,e.return,k)}}break;case 1:nt(t,e),mt(e),r&512&&n!==null&&Hn(n,n.return);break;case 5:if(nt(t,e),mt(e),r&512&&n!==null&&Hn(n,n.return),e.flags&32){var o=e.stateNode;try{Kr(o,"")}catch(k){re(e,e.return,k)}}if(r&4&&(o=e.stateNode,o!=null)){var i=e.memoizedProps,l=n!==null?n.memoizedProps:i,a=e.type,s=e.updateQueue;if(e.updateQueue=null,s!==null)try{a==="input"&&i.type==="radio"&&i.name!=null&&pd(o,i),na(a,l);var c=na(a,i);for(l=0;l<s.length;l+=2){var m=s[l],h=s[l+1];m==="style"?xd(o,h):m==="dangerouslySetInnerHTML"?gd(o,h):m==="children"?Kr(o,h):es(o,m,h,c)}switch(a){case"input":Xl(o,i);break;case"textarea":hd(o,i);break;case"select":var f=o._wrapperState.wasMultiple;o._wrapperState.wasMultiple=!!i.multiple;var w=i.value;w!=null?Wn(o,!!i.multiple,w,!1):f!==!!i.multiple&&(i.defaultValue!=null?Wn(o,!!i.multiple,i.defaultValue,!0):Wn(o,!!i.multiple,i.multiple?[]:"",!1))}o[no]=i}catch(k){re(e,e.return,k)}}break;case 6:if(nt(t,e),mt(e),r&4){if(e.stateNode===null)throw Error(E(162));o=e.stateNode,i=e.memoizedProps;try{o.nodeValue=i}catch(k){re(e,e.return,k)}}break;case 3:if(nt(t,e),mt(e),r&4&&n!==null&&n.memoizedState.isDehydrated)try{Xr(t.containerInfo)}catch(k){re(e,e.return,k)}break;case 4:nt(t,e),mt(e);break;case 13:nt(t,e),mt(e),o=e.child,o.flags&8192&&(i=o.memoizedState!==null,o.stateNode.isHidden=i,!i||o.alternate!==null&&o.alternate.memoizedState!==null||(Os=oe())),r&4&&ic(e);break;case 22:if(m=n!==null&&n.memoizedState!==null,e.mode&1?(be=(c=be)||m,nt(t,e),be=c):nt(t,e),mt(e),r&8192){if(c=e.memoizedState!==null,(e.stateNode.isHidden=c)&&!m&&e.mode&1)for(L=e,m=e.child;m!==null;){for(h=L=m;L!==null;){switch(f=L,w=f.child,f.tag){case 0:case 11:case 14:case 15:Ir(4,f,f.return);break;case 1:Hn(f,f.return);var v=f.stateNode;if(typeof v.componentWillUnmount=="function"){r=f,n=f.return;try{t=r,v.props=t.memoizedProps,v.state=t.memoizedState,v.componentWillUnmount()}catch(k){re(r,n,k)}}break;case 5:Hn(f,f.return);break;case 22:if(f.memoizedState!==null){ac(h);continue}}w!==null?(w.return=f,L=w):ac(h)}m=m.sibling}e:for(m=null,h=e;;){if(h.tag===5){if(m===null){m=h;try{o=h.stateNode,c?(i=o.style,typeof i.setProperty=="function"?i.setProperty("display","none","important"):i.display="none"):(a=h.stateNode,s=h.memoizedProps.style,l=s!=null&&s.hasOwnProperty("display")?s.display:null,a.style.display=yd("display",l))}catch(k){re(e,e.return,k)}}}else if(h.tag===6){if(m===null)try{h.stateNode.nodeValue=c?"":h.memoizedProps}catch(k){re(e,e.return,k)}}else if((h.tag!==22&&h.tag!==23||h.memoizedState===null||h===e)&&h.child!==null){h.child.return=h,h=h.child;continue}if(h===e)break e;for(;h.sibling===null;){if(h.return===null||h.return===e)break e;m===h&&(m=null),h=h.return}m===h&&(m=null),h.sibling.return=h.return,h=h.sibling}}break;case 19:nt(t,e),mt(e),r&4&&ic(e);break;case 21:break;default:nt(t,e),mt(e)}}function mt(e){var t=e.flags;if(t&2){try{e:{for(var n=e.return;n!==null;){if(Wf(n)){var r=n;break e}n=n.return}throw Error(E(160))}switch(r.tag){case 5:var o=r.stateNode;r.flags&32&&(Kr(o,""),r.flags&=-33);var i=oc(e);Na(e,i,o);break;case 3:case 4:var l=r.stateNode.containerInfo,a=oc(e);Pa(e,a,l);break;default:throw Error(E(161))}}catch(s){re(e,e.return,s)}e.flags&=-3}t&4096&&(e.flags&=-4097)}function cm(e,t,n){L=e,Kf(e)}function Kf(e,t,n){for(var r=(e.mode&1)!==0;L!==null;){var o=L,i=o.child;if(o.tag===22&&r){var l=o.memoizedState!==null||Bo;if(!l){var a=o.alternate,s=a!==null&&a.memoizedState!==null||be;a=Bo;var c=be;if(Bo=l,(be=s)&&!c)for(L=o;L!==null;)l=L,s=l.child,l.tag===22&&l.memoizedState!==null?sc(o):s!==null?(s.return=l,L=s):sc(o);for(;i!==null;)L=i,Kf(i),i=i.sibling;L=o,Bo=a,be=c}lc(e)}else o.subtreeFlags&8772&&i!==null?(i.return=o,L=i):lc(e)}}function lc(e){for(;L!==null;){var t=L;if(t.flags&8772){var n=t.alternate;try{if(t.flags&8772)switch(t.tag){case 0:case 11:case 15:be||Vi(5,t);break;case 1:var r=t.stateNode;if(t.flags&4&&!be)if(n===null)r.componentDidMount();else{var o=t.elementType===t.type?n.memoizedProps:ot(t.type,n.memoizedProps);r.componentDidUpdate(o,n.memoizedState,r.__reactInternalSnapshotBeforeUpdate)}var i=t.updateQueue;i!==null&&Wu(t,i,r);break;case 3:var l=t.updateQueue;if(l!==null){if(n=null,t.child!==null)switch(t.child.tag){case 5:n=t.child.stateNode;break;case 1:n=t.child.stateNode}Wu(t,l,n)}break;case 5:var a=t.stateNode;if(n===null&&t.flags&4){n=a;var s=t.memoizedProps;switch(t.type){case"button":case"input":case"select":case"textarea":s.autoFocus&&n.focus();break;case"img":s.src&&(n.src=s.src)}}break;case 6:break;case 4:break;case 12:break;case 13:if(t.memoizedState===null){var c=t.alternate;if(c!==null){var m=c.memoizedState;if(m!==null){var h=m.dehydrated;h!==null&&Xr(h)}}}break;case 19:case 17:case 21:case 22:case 23:case 25:break;default:throw Error(E(163))}be||t.flags&512&&La(t)}catch(f){re(t,t.return,f)}}if(t===e){L=null;break}if(n=t.sibling,n!==null){n.return=t.return,L=n;break}L=t.return}}function ac(e){for(;L!==null;){var t=L;if(t===e){L=null;break}var n=t.sibling;if(n!==null){n.return=t.return,L=n;break}L=t.return}}function sc(e){for(;L!==null;){var t=L;try{switch(t.tag){case 0:case 11:case 15:var n=t.return;try{Vi(4,t)}catch(s){re(t,n,s)}break;case 1:var r=t.stateNode;if(typeof r.componentDidMount=="function"){var o=t.return;try{r.componentDidMount()}catch(s){re(t,o,s)}}var i=t.return;try{La(t)}catch(s){re(t,i,s)}break;case 5:var l=t.return;try{La(t)}catch(s){re(t,l,s)}}}catch(s){re(t,t.return,s)}if(t===e){L=null;break}var a=t.sibling;if(a!==null){a.return=t.return,L=a;break}L=t.return}}var dm=Math.ceil,_i=Nt.ReactCurrentDispatcher,Ps=Nt.ReactCurrentOwner,Xe=Nt.ReactCurrentBatchConfig,B=0,ge=null,ue=null,ve=0,Be=0,Un=rn(0),he=0,so=null,vn=0,Gi=0,Ns=0,Br=null,Ne=null,Os=0,rr=1/0,St=null,Ei=!1,Oa=null,Qt=null,Fo=!1,Dt=null,ji=0,Fr=0,Ra=null,Jo=-1,qo=0;function Te(){return B&6?oe():Jo!==-1?Jo:Jo=oe()}function Zt(e){return e.mode&1?B&2&&ve!==0?ve&-ve:Yh.transition!==null?(qo===0&&(qo=Ld()),qo):(e=V,e!==0||(e=window.event,e=e===void 0?16:Ad(e.type)),e):1}function ct(e,t,n,r){if(50<Fr)throw Fr=0,Ra=null,Error(E(185));po(e,n,r),(!(B&2)||e!==ge)&&(e===ge&&(!(B&2)&&(Gi|=n),he===4&&Bt(e,ve)),ze(e,r),n===1&&B===0&&!(t.mode&1)&&(rr=oe()+500,Hi&&on()))}function ze(e,t){var n=e.callbackNode;Y0(e,t);var r=di(e,e===ge?ve:0);if(r===0)n!==null&&yu(n),e.callbackNode=null,e.callbackPriority=0;else if(t=r&-r,e.callbackPriority!==t){if(n!=null&&yu(n),t===1)e.tag===0?Kh(uc.bind(null,e)):nf(uc.bind(null,e)),Uh(function(){!(B&6)&&on()}),n=null;else{switch(Pd(r)){case 1:n=is;break;case 4:n=jd;break;case 16:n=ci;break;case 536870912:n=Td;break;default:n=ci}n=tp(n,Yf.bind(null,e))}e.callbackPriority=t,e.callbackNode=n}}function Yf(e,t){if(Jo=-1,qo=0,B&6)throw Error(E(327));var n=e.callbackNode;if(Qn()&&e.callbackNode!==n)return null;var r=di(e,e===ge?ve:0);if(r===0)return null;if(r&30||r&e.expiredLanes||t)t=Ti(e,r);else{t=r;var o=B;B|=2;var i=Zf();(ge!==e||ve!==t)&&(St=null,rr=oe()+500,fn(e,t));do try{hm();break}catch(a){Qf(e,a)}while(!0);xs(),_i.current=i,B=o,ue!==null?t=0:(ge=null,ve=0,t=he)}if(t!==0){if(t===2&&(o=aa(e),o!==0&&(r=o,t=Ma(e,o))),t===1)throw n=so,fn(e,0),Bt(e,r),ze(e,oe()),n;if(t===6)Bt(e,r);else{if(o=e.current.alternate,!(r&30)&&!fm(o)&&(t=Ti(e,r),t===2&&(i=aa(e),i!==0&&(r=i,t=Ma(e,i))),t===1))throw n=so,fn(e,0),Bt(e,r),ze(e,oe()),n;switch(e.finishedWork=o,e.finishedLanes=r,t){case 0:case 1:throw Error(E(345));case 2:an(e,Ne,St);break;case 3:if(Bt(e,r),(r&130023424)===r&&(t=Os+500-oe(),10<t)){if(di(e,0)!==0)break;if(o=e.suspendedLanes,(o&r)!==r){Te(),e.pingedLanes|=e.suspendedLanes&o;break}e.timeoutHandle=ma(an.bind(null,e,Ne,St),t);break}an(e,Ne,St);break;case 4:if(Bt(e,r),(r&4194240)===r)break;for(t=e.eventTimes,o=-1;0<r;){var l=31-ut(r);i=1<<l,l=t[l],l>o&&(o=l),r&=~i}if(r=o,r=oe()-r,r=(120>r?120:480>r?480:1080>r?1080:1920>r?1920:3e3>r?3e3:4320>r?4320:1960*dm(r/1960))-r,10<r){e.timeoutHandle=ma(an.bind(null,e,Ne,St),r);break}an(e,Ne,St);break;case 5:an(e,Ne,St);break;default:throw Error(E(329))}}}return ze(e,oe()),e.callbackNode===n?Yf.bind(null,e):null}function Ma(e,t){var n=Br;return e.current.memoizedState.isDehydrated&&(fn(e,t).flags|=256),e=Ti(e,t),e!==2&&(t=Ne,Ne=n,t!==null&&za(t)),e}function za(e){Ne===null?Ne=e:Ne.push.apply(Ne,e)}function fm(e){for(var t=e;;){if(t.flags&16384){var n=t.updateQueue;if(n!==null&&(n=n.stores,n!==null))for(var r=0;r<n.length;r++){var o=n[r],i=o.getSnapshot;o=o.value;try{if(!ft(i(),o))return!1}catch{return!1}}}if(n=t.child,t.subtreeFlags&16384&&n!==null)n.return=t,t=n;else{if(t===e)break;for(;t.sibling===null;){if(t.return===null||t.return===e)return!0;t=t.return}t.sibling.return=t.return,t=t.sibling}}return!0}function Bt(e,t){for(t&=~Ns,t&=~Gi,e.suspendedLanes|=t,e.pingedLanes&=~t,e=e.expirationTimes;0<t;){var n=31-ut(t),r=1<<n;e[n]=-1,t&=~r}}function uc(e){if(B&6)throw Error(E(327));Qn();var t=di(e,0);if(!(t&1))return ze(e,oe()),null;var n=Ti(e,t);if(e.tag!==0&&n===2){var r=aa(e);r!==0&&(t=r,n=Ma(e,r))}if(n===1)throw n=so,fn(e,0),Bt(e,t),ze(e,oe()),n;if(n===6)throw Error(E(345));return e.finishedWork=e.current.alternate,e.finishedLanes=t,an(e,Ne,St),ze(e,oe()),null}function Rs(e,t){var n=B;B|=1;try{return e(t)}finally{B=n,B===0&&(rr=oe()+500,Hi&&on())}}function wn(e){Dt!==null&&Dt.tag===0&&!(B&6)&&Qn();var t=B;B|=1;var n=Xe.transition,r=V;try{if(Xe.transition=null,V=1,e)return e()}finally{V=r,Xe.transition=n,B=t,!(B&6)&&on()}}function Ms(){Be=Un.current,Z(Un)}function fn(e,t){e.finishedWork=null,e.finishedLanes=0;var n=e.timeoutHandle;if(n!==-1&&(e.timeoutHandle=-1,Hh(n)),ue!==null)for(n=ue.return;n!==null;){var r=n;switch(ms(r),r.tag){case 1:r=r.type.childContextTypes,r!=null&&gi();break;case 3:tr(),Z(Re),Z(Ce),bs();break;case 5:$s(r);break;case 4:tr();break;case 13:Z(J);break;case 19:Z(J);break;case 10:vs(r.type._context);break;case 22:case 23:Ms()}n=n.return}if(ge=e,ue=e=Xt(e.current,null),ve=Be=t,he=0,so=null,Ns=Gi=vn=0,Ne=Br=null,cn!==null){for(t=0;t<cn.length;t++)if(n=cn[t],r=n.interleaved,r!==null){n.interleaved=null;var o=r.next,i=n.pending;if(i!==null){var l=i.next;i.next=o,r.next=l}n.pending=r}cn=null}return e}function Qf(e,t){do{var n=ue;try{if(xs(),Qo.current=Ci,bi){for(var r=ee.memoizedState;r!==null;){var o=r.queue;o!==null&&(o.pending=null),r=r.next}bi=!1}if(xn=0,me=fe=ee=null,Ar=!1,io=0,Ps.current=null,n===null||n.return===null){he=1,so=t,ue=null;break}e:{var i=e,l=n.return,a=n,s=t;if(t=ve,a.flags|=32768,s!==null&&typeof s=="object"&&typeof s.then=="function"){var c=s,m=a,h=m.tag;if(!(m.mode&1)&&(h===0||h===11||h===15)){var f=m.alternate;f?(m.updateQueue=f.updateQueue,m.memoizedState=f.memoizedState,m.lanes=f.lanes):(m.updateQueue=null,m.memoizedState=null)}var w=Zu(l);if(w!==null){w.flags&=-257,Xu(w,l,a,i,t),w.mode&1&&Qu(i,c,t),t=w,s=c;var v=t.updateQueue;if(v===null){var k=new Set;k.add(s),t.updateQueue=k}else v.add(s);break e}else{if(!(t&1)){Qu(i,c,t),zs();break e}s=Error(E(426))}}else if(X&&a.mode&1){var _=Zu(l);if(_!==null){!(_.flags&65536)&&(_.flags|=256),Xu(_,l,a,i,t),gs(nr(s,a));break e}}i=s=nr(s,a),he!==4&&(he=2),Br===null?Br=[i]:Br.push(i),i=l;do{switch(i.tag){case 3:i.flags|=65536,t&=-t,i.lanes|=t;var p=Nf(i,s,t);Uu(i,p);break e;case 1:a=s;var d=i.type,g=i.stateNode;if(!(i.flags&128)&&(typeof d.getDerivedStateFromError=="function"||g!==null&&typeof g.componentDidCatch=="function"&&(Qt===null||!Qt.has(g)))){i.flags|=65536,t&=-t,i.lanes|=t;var S=Of(i,a,t);Uu(i,S);break e}}i=i.return}while(i!==null)}Jf(n)}catch(y){t=y,ue===n&&n!==null&&(ue=n=n.return);continue}break}while(!0)}function Zf(){var e=_i.current;return _i.current=Ci,e===null?Ci:e}function zs(){(he===0||he===3||he===2)&&(he=4),ge===null||!(vn&268435455)&&!(Gi&268435455)||Bt(ge,ve)}function Ti(e,t){var n=B;B|=2;var r=Zf();(ge!==e||ve!==t)&&(St=null,fn(e,t));do try{pm();break}catch(o){Qf(e,o)}while(!0);if(xs(),B=n,_i.current=r,ue!==null)throw Error(E(261));return ge=null,ve=0,he}function pm(){for(;ue!==null;)Xf(ue)}function hm(){for(;ue!==null&&!B0();)Xf(ue)}function Xf(e){var t=ep(e.alternate,e,Be);e.memoizedProps=e.pendingProps,t===null?Jf(e):ue=t,Ps.current=null}function Jf(e){var t=e;do{var n=t.alternate;if(e=t.return,t.flags&32768){if(n=am(n,t),n!==null){n.flags&=32767,ue=n;return}if(e!==null)e.flags|=32768,e.subtreeFlags=0,e.deletions=null;else{he=6,ue=null;return}}else if(n=lm(n,t,Be),n!==null){ue=n;return}if(t=t.sibling,t!==null){ue=t;return}ue=t=e}while(t!==null);he===0&&(he=5)}function an(e,t,n){var r=V,o=Xe.transition;try{Xe.transition=null,V=1,mm(e,t,n,r)}finally{Xe.transition=o,V=r}return null}function mm(e,t,n,r){do Qn();while(Dt!==null);if(B&6)throw Error(E(327));n=e.finishedWork;var o=e.finishedLanes;if(n===null)return null;if(e.finishedWork=null,e.finishedLanes=0,n===e.current)throw Error(E(177));e.callbackNode=null,e.callbackPriority=0;var i=n.lanes|n.childLanes;if(Q0(e,i),e===ge&&(ue=ge=null,ve=0),!(n.subtreeFlags&2064)&&!(n.flags&2064)||Fo||(Fo=!0,tp(ci,function(){return Qn(),null})),i=(n.flags&15990)!==0,n.subtreeFlags&15990||i){i=Xe.transition,Xe.transition=null;var l=V;V=1;var a=B;B|=4,Ps.current=null,um(e,n),Gf(n,e),Mh(pa),fi=!!fa,pa=fa=null,e.current=n,cm(n),F0(),B=a,V=l,Xe.transition=i}else e.current=n;if(Fo&&(Fo=!1,Dt=e,ji=o),i=e.pendingLanes,i===0&&(Qt=null),U0(n.stateNode),ze(e,oe()),t!==null)for(r=e.onRecoverableError,n=0;n<t.length;n++)o=t[n],r(o.value,{componentStack:o.stack,digest:o.digest});if(Ei)throw Ei=!1,e=Oa,Oa=null,e;return ji&1&&e.tag!==0&&Qn(),i=e.pendingLanes,i&1?e===Ra?Fr++:(Fr=0,Ra=e):Fr=0,on(),null}function Qn(){if(Dt!==null){var e=Pd(ji),t=Xe.transition,n=V;try{if(Xe.transition=null,V=16>e?16:e,Dt===null)var r=!1;else{if(e=Dt,Dt=null,ji=0,B&6)throw Error(E(331));var o=B;for(B|=4,L=e.current;L!==null;){var i=L,l=i.child;if(L.flags&16){var a=i.deletions;if(a!==null){for(var s=0;s<a.length;s++){var c=a[s];for(L=c;L!==null;){var m=L;switch(m.tag){case 0:case 11:case 15:Ir(8,m,i)}var h=m.child;if(h!==null)h.return=m,L=h;else for(;L!==null;){m=L;var f=m.sibling,w=m.return;if(Uf(m),m===c){L=null;break}if(f!==null){f.return=w,L=f;break}L=w}}}var v=i.alternate;if(v!==null){var k=v.child;if(k!==null){v.child=null;do{var _=k.sibling;k.sibling=null,k=_}while(k!==null)}}L=i}}if(i.subtreeFlags&2064&&l!==null)l.return=i,L=l;else e:for(;L!==null;){if(i=L,i.flags&2048)switch(i.tag){case 0:case 11:case 15:Ir(9,i,i.return)}var p=i.sibling;if(p!==null){p.return=i.return,L=p;break e}L=i.return}}var d=e.current;for(L=d;L!==null;){l=L;var g=l.child;if(l.subtreeFlags&2064&&g!==null)g.return=l,L=g;else e:for(l=d;L!==null;){if(a=L,a.flags&2048)try{switch(a.tag){case 0:case 11:case 15:Vi(9,a)}}catch(y){re(a,a.return,y)}if(a===l){L=null;break e}var S=a.sibling;if(S!==null){S.return=a.return,L=S;break e}L=a.return}}if(B=o,on(),vt&&typeof vt.onPostCommitFiberRoot=="function")try{vt.onPostCommitFiberRoot(Ai,e)}catch{}r=!0}return r}finally{V=n,Xe.transition=t}}return!1}function cc(e,t,n){t=nr(n,t),t=Nf(e,t,1),e=Yt(e,t,1),t=Te(),e!==null&&(po(e,1,t),ze(e,t))}function re(e,t,n){if(e.tag===3)cc(e,e,n);else for(;t!==null;){if(t.tag===3){cc(t,e,n);break}else if(t.tag===1){var r=t.stateNode;if(typeof t.type.getDerivedStateFromError=="function"||typeof r.componentDidCatch=="function"&&(Qt===null||!Qt.has(r))){e=nr(n,e),e=Of(t,e,1),t=Yt(t,e,1),e=Te(),t!==null&&(po(t,1,e),ze(t,e));break}}t=t.return}}function gm(e,t,n){var r=e.pingCache;r!==null&&r.delete(t),t=Te(),e.pingedLanes|=e.suspendedLanes&n,ge===e&&(ve&n)===n&&(he===4||he===3&&(ve&130023424)===ve&&500>oe()-Os?fn(e,0):Ns|=n),ze(e,t)}function qf(e,t){t===0&&(e.mode&1?(t=Lo,Lo<<=1,!(Lo&130023424)&&(Lo=4194304)):t=1);var n=Te();e=Lt(e,t),e!==null&&(po(e,t,n),ze(e,n))}function ym(e){var t=e.memoizedState,n=0;t!==null&&(n=t.retryLane),qf(e,n)}function xm(e,t){var n=0;switch(e.tag){case 13:var r=e.stateNode,o=e.memoizedState;o!==null&&(n=o.retryLane);break;case 19:r=e.stateNode;break;default:throw Error(E(314))}r!==null&&r.delete(t),qf(e,n)}var ep;ep=function(e,t,n){if(e!==null)if(e.memoizedProps!==t.pendingProps||Re.current)Oe=!0;else{if(!(e.lanes&n)&&!(t.flags&128))return Oe=!1,im(e,t,n);Oe=!!(e.flags&131072)}else Oe=!1,X&&t.flags&1048576&&rf(t,vi,t.index);switch(t.lanes=0,t.tag){case 2:var r=t.type;Xo(e,t),e=t.pendingProps;var o=Jn(t,Ce.current);Yn(t,n),o=_s(null,t,r,e,o,n);var i=Es();return t.flags|=1,typeof o=="object"&&o!==null&&typeof o.render=="function"&&o.$$typeof===void 0?(t.tag=1,t.memoizedState=null,t.updateQueue=null,Me(r)?(i=!0,yi(t)):i=!1,t.memoizedState=o.state!==null&&o.state!==void 0?o.state:null,ks(t),o.updater=Wi,t.stateNode=o,o._reactInternals=t,Sa(t,r,e,n),t=Ca(null,t,r,!0,i,n)):(t.tag=0,X&&i&&hs(t),Ee(null,t,o,n),t=t.child),t;case 16:r=t.elementType;e:{switch(Xo(e,t),e=t.pendingProps,o=r._init,r=o(r._payload),t.type=r,o=t.tag=wm(r),e=ot(r,e),o){case 0:t=ba(null,t,r,e,n);break e;case 1:t=ec(null,t,r,e,n);break e;case 11:t=Ju(null,t,r,e,n);break e;case 14:t=qu(null,t,r,ot(r.type,e),n);break e}throw Error(E(306,r,""))}return t;case 0:return r=t.type,o=t.pendingProps,o=t.elementType===r?o:ot(r,o),ba(e,t,r,o,n);case 1:return r=t.type,o=t.pendingProps,o=t.elementType===r?o:ot(r,o),ec(e,t,r,o,n);case 3:e:{if(Af(t),e===null)throw Error(E(387));r=t.pendingProps,i=t.memoizedState,o=i.element,cf(e,t),Si(t,r,null,n);var l=t.memoizedState;if(r=l.element,i.isDehydrated)if(i={element:r,isDehydrated:!1,cache:l.cache,pendingSuspenseBoundaries:l.pendingSuspenseBoundaries,transitions:l.transitions},t.updateQueue.baseState=i,t.memoizedState=i,t.flags&256){o=nr(Error(E(423)),t),t=tc(e,t,r,n,o);break e}else if(r!==o){o=nr(Error(E(424)),t),t=tc(e,t,r,n,o);break e}else for(De=Kt(t.stateNode.containerInfo.firstChild),He=t,X=!0,at=null,n=sf(t,null,r,n),t.child=n;n;)n.flags=n.flags&-3|4096,n=n.sibling;else{if(qn(),r===o){t=Pt(e,t,n);break e}Ee(e,t,r,n)}t=t.child}return t;case 5:return df(t),e===null&&va(t),r=t.type,o=t.pendingProps,i=e!==null?e.memoizedProps:null,l=o.children,ha(r,o)?l=null:i!==null&&ha(r,i)&&(t.flags|=32),zf(e,t),Ee(e,t,l,n),t.child;case 6:return e===null&&va(t),null;case 13:return If(e,t,n);case 4:return Ss(t,t.stateNode.containerInfo),r=t.pendingProps,e===null?t.child=er(t,null,r,n):Ee(e,t,r,n),t.child;case 11:return r=t.type,o=t.pendingProps,o=t.elementType===r?o:ot(r,o),Ju(e,t,r,o,n);case 7:return Ee(e,t,t.pendingProps,n),t.child;case 8:return Ee(e,t,t.pendingProps.children,n),t.child;case 12:return Ee(e,t,t.pendingProps.children,n),t.child;case 10:e:{if(r=t.type._context,o=t.pendingProps,i=t.memoizedProps,l=o.value,K(wi,r._currentValue),r._currentValue=l,i!==null)if(ft(i.value,l)){if(i.children===o.children&&!Re.current){t=Pt(e,t,n);break e}}else for(i=t.child,i!==null&&(i.return=t);i!==null;){var a=i.dependencies;if(a!==null){l=i.child;for(var s=a.firstContext;s!==null;){if(s.context===r){if(i.tag===1){s=Et(-1,n&-n),s.tag=2;var c=i.updateQueue;if(c!==null){c=c.shared;var m=c.pending;m===null?s.next=s:(s.next=m.next,m.next=s),c.pending=s}}i.lanes|=n,s=i.alternate,s!==null&&(s.lanes|=n),wa(i.return,n,t),a.lanes|=n;break}s=s.next}}else if(i.tag===10)l=i.type===t.type?null:i.child;else if(i.tag===18){if(l=i.return,l===null)throw Error(E(341));l.lanes|=n,a=l.alternate,a!==null&&(a.lanes|=n),wa(l,n,t),l=i.sibling}else l=i.child;if(l!==null)l.return=i;else for(l=i;l!==null;){if(l===t){l=null;break}if(i=l.sibling,i!==null){i.return=l.return,l=i;break}l=l.return}i=l}Ee(e,t,o.children,n),t=t.child}return t;case 9:return o=t.type,r=t.pendingProps.children,Yn(t,n),o=Je(o),r=r(o),t.flags|=1,Ee(e,t,r,n),t.child;case 14:return r=t.type,o=ot(r,t.pendingProps),o=ot(r.type,o),qu(e,t,r,o,n);case 15:return Rf(e,t,t.type,t.pendingProps,n);case 17:return r=t.type,o=t.pendingProps,o=t.elementType===r?o:ot(r,o),Xo(e,t),t.tag=1,Me(r)?(e=!0,yi(t)):e=!1,Yn(t,n),Pf(t,r,o),Sa(t,r,o,n),Ca(null,t,r,!0,e,n);case 19:return Bf(e,t,n);case 22:return Mf(e,t,n)}throw Error(E(156,t.tag))};function tp(e,t){return Ed(e,t)}function vm(e,t,n,r){this.tag=e,this.key=n,this.sibling=this.child=this.return=this.stateNode=this.type=this.elementType=null,this.index=0,this.ref=null,this.pendingProps=t,this.dependencies=this.memoizedState=this.updateQueue=this.memoizedProps=null,this.mode=r,this.subtreeFlags=this.flags=0,this.deletions=null,this.childLanes=this.lanes=0,this.alternate=null}function Ze(e,t,n,r){return new vm(e,t,n,r)}function As(e){return e=e.prototype,!(!e||!e.isReactComponent)}function wm(e){if(typeof e=="function")return As(e)?1:0;if(e!=null){if(e=e.$$typeof,e===ns)return 11;if(e===rs)return 14}return 2}function Xt(e,t){var n=e.alternate;return n===null?(n=Ze(e.tag,t,e.key,e.mode),n.elementType=e.elementType,n.type=e.type,n.stateNode=e.stateNode,n.alternate=e,e.alternate=n):(n.pendingProps=t,n.type=e.type,n.flags=0,n.subtreeFlags=0,n.deletions=null),n.flags=e.flags&14680064,n.childLanes=e.childLanes,n.lanes=e.lanes,n.child=e.child,n.memoizedProps=e.memoizedProps,n.memoizedState=e.memoizedState,n.updateQueue=e.updateQueue,t=e.dependencies,n.dependencies=t===null?null:{lanes:t.lanes,firstContext:t.firstContext},n.sibling=e.sibling,n.index=e.index,n.ref=e.ref,n}function ei(e,t,n,r,o,i){var l=2;if(r=e,typeof e=="function")As(e)&&(l=1);else if(typeof e=="string")l=5;else e:switch(e){case On:return pn(n.children,o,i,t);case ts:l=8,o|=8;break;case Gl:return e=Ze(12,n,t,o|2),e.elementType=Gl,e.lanes=i,e;case Kl:return e=Ze(13,n,t,o),e.elementType=Kl,e.lanes=i,e;case Yl:return e=Ze(19,n,t,o),e.elementType=Yl,e.lanes=i,e;case cd:return Ki(n,o,i,t);default:if(typeof e=="object"&&e!==null)switch(e.$$typeof){case sd:l=10;break e;case ud:l=9;break e;case ns:l=11;break e;case rs:l=14;break e;case zt:l=16,r=null;break e}throw Error(E(130,e==null?e:typeof e,""))}return t=Ze(l,n,t,o),t.elementType=e,t.type=r,t.lanes=i,t}function pn(e,t,n,r){return e=Ze(7,e,r,t),e.lanes=n,e}function Ki(e,t,n,r){return e=Ze(22,e,r,t),e.elementType=cd,e.lanes=n,e.stateNode={isHidden:!1},e}function Pl(e,t,n){return e=Ze(6,e,null,t),e.lanes=n,e}function Nl(e,t,n){return t=Ze(4,e.children!==null?e.children:[],e.key,t),t.lanes=n,t.stateNode={containerInfo:e.containerInfo,pendingChildren:null,implementation:e.implementation},t}function km(e,t,n,r,o){this.tag=t,this.containerInfo=e,this.finishedWork=this.pingCache=this.current=this.pendingChildren=null,this.timeoutHandle=-1,this.callbackNode=this.pendingContext=this.context=null,this.callbackPriority=0,this.eventTimes=fl(0),this.expirationTimes=fl(-1),this.entangledLanes=this.finishedLanes=this.mutableReadLanes=this.expiredLanes=this.pingedLanes=this.suspendedLanes=this.pendingLanes=0,this.entanglements=fl(0),this.identifierPrefix=r,this.onRecoverableError=o,this.mutableSourceEagerHydrationData=null}function Is(e,t,n,r,o,i,l,a,s){return e=new km(e,t,n,a,s),t===1?(t=1,i===!0&&(t|=8)):t=0,i=Ze(3,null,null,t),e.current=i,i.stateNode=e,i.memoizedState={element:r,isDehydrated:n,cache:null,transitions:null,pendingSuspenseBoundaries:null},ks(i),e}function Sm(e,t,n){var r=3<arguments.length&&arguments[3]!==void 0?arguments[3]:null;return{$$typeof:Nn,key:r==null?null:""+r,children:e,containerInfo:t,implementation:n}}function np(e){if(!e)return tn;e=e._reactInternals;e:{if($n(e)!==e||e.tag!==1)throw Error(E(170));var t=e;do{switch(t.tag){case 3:t=t.stateNode.context;break e;case 1:if(Me(t.type)){t=t.stateNode.__reactInternalMemoizedMergedChildContext;break e}}t=t.return}while(t!==null);throw Error(E(171))}if(e.tag===1){var n=e.type;if(Me(n))return tf(e,n,t)}return t}function rp(e,t,n,r,o,i,l,a,s){return e=Is(n,r,!0,e,o,i,l,a,s),e.context=np(null),n=e.current,r=Te(),o=Zt(n),i=Et(r,o),i.callback=t??null,Yt(n,i,o),e.current.lanes=o,po(e,o,r),ze(e,r),e}function Yi(e,t,n,r){var o=t.current,i=Te(),l=Zt(o);return n=np(n),t.context===null?t.context=n:t.pendingContext=n,t=Et(i,l),t.payload={element:e},r=r===void 0?null:r,r!==null&&(t.callback=r),e=Yt(o,t,l),e!==null&&(ct(e,o,l,i),Yo(e,o,l)),l}function Li(e){if(e=e.current,!e.child)return null;switch(e.child.tag){case 5:return e.child.stateNode;default:return e.child.stateNode}}function dc(e,t){if(e=e.memoizedState,e!==null&&e.dehydrated!==null){var n=e.retryLane;e.retryLane=n!==0&&n<t?n:t}}function Bs(e,t){dc(e,t),(e=e.alternate)&&dc(e,t)}function $m(){return null}var op=typeof reportError=="function"?reportError:function(e){console.error(e)};function Fs(e){this._internalRoot=e}Qi.prototype.render=Fs.prototype.render=function(e){var t=this._internalRoot;if(t===null)throw Error(E(409));Yi(e,t,null,null)};Qi.prototype.unmount=Fs.prototype.unmount=function(){var e=this._internalRoot;if(e!==null){this._internalRoot=null;var t=e.containerInfo;wn(function(){Yi(null,e,null,null)}),t[Tt]=null}};function Qi(e){this._internalRoot=e}Qi.prototype.unstable_scheduleHydration=function(e){if(e){var t=Rd();e={blockedOn:null,target:e,priority:t};for(var n=0;n<It.length&&t!==0&&t<It[n].priority;n++);It.splice(n,0,e),n===0&&zd(e)}};function Ds(e){return!(!e||e.nodeType!==1&&e.nodeType!==9&&e.nodeType!==11)}function Zi(e){return!(!e||e.nodeType!==1&&e.nodeType!==9&&e.nodeType!==11&&(e.nodeType!==8||e.nodeValue!==" react-mount-point-unstable "))}function fc(){}function bm(e,t,n,r,o){if(o){if(typeof r=="function"){var i=r;r=function(){var c=Li(l);i.call(c)}}var l=rp(t,r,e,0,null,!1,!1,"",fc);return e._reactRootContainer=l,e[Tt]=l.current,eo(e.nodeType===8?e.parentNode:e),wn(),l}for(;o=e.lastChild;)e.removeChild(o);if(typeof r=="function"){var a=r;r=function(){var c=Li(s);a.call(c)}}var s=Is(e,0,!1,null,null,!1,!1,"",fc);return e._reactRootContainer=s,e[Tt]=s.current,eo(e.nodeType===8?e.parentNode:e),wn(function(){Yi(t,s,n,r)}),s}function Xi(e,t,n,r,o){var i=n._reactRootContainer;if(i){var l=i;if(typeof o=="function"){var a=o;o=function(){var s=Li(l);a.call(s)}}Yi(t,l,e,o)}else l=bm(n,t,e,o,r);return Li(l)}Nd=function(e){switch(e.tag){case 3:var t=e.stateNode;if(t.current.memoizedState.isDehydrated){var n=Er(t.pendingLanes);n!==0&&(ls(t,n|1),ze(t,oe()),!(B&6)&&(rr=oe()+500,on()))}break;case 13:wn(function(){var r=Lt(e,1);if(r!==null){var o=Te();ct(r,e,1,o)}}),Bs(e,1)}};as=function(e){if(e.tag===13){var t=Lt(e,134217728);if(t!==null){var n=Te();ct(t,e,134217728,n)}Bs(e,134217728)}};Od=function(e){if(e.tag===13){var t=Zt(e),n=Lt(e,t);if(n!==null){var r=Te();ct(n,e,t,r)}Bs(e,t)}};Rd=function(){return V};Md=function(e,t){var n=V;try{return V=e,t()}finally{V=n}};oa=function(e,t,n){switch(t){case"input":if(Xl(e,n),t=n.name,n.type==="radio"&&t!=null){for(n=e;n.parentNode;)n=n.parentNode;for(n=n.querySelectorAll("input[name="+JSON.stringify(""+t)+'][type="radio"]'),t=0;t<n.length;t++){var r=n[t];if(r!==e&&r.form===e.form){var o=Di(r);if(!o)throw Error(E(90));fd(r),Xl(r,o)}}}break;case"textarea":hd(e,n);break;case"select":t=n.value,t!=null&&Wn(e,!!n.multiple,t,!1)}};kd=Rs;Sd=wn;var Cm={usingClientEntryPoint:!1,Events:[mo,An,Di,vd,wd,Rs]},Sr={findFiberByHostInstance:un,bundleType:0,version:"18.3.1",rendererPackageName:"react-dom"},_m={bundleType:Sr.bundleType,version:Sr.version,rendererPackageName:Sr.rendererPackageName,rendererConfig:Sr.rendererConfig,overrideHookState:null,overrideHookStateDeletePath:null,overrideHookStateRenamePath:null,overrideProps:null,overridePropsDeletePath:null,overridePropsRenamePath:null,setErrorHandler:null,setSuspenseHandler:null,scheduleUpdate:null,currentDispatcherRef:Nt.ReactCurrentDispatcher,findHostInstanceByFiber:function(e){return e=Cd(e),e===null?null:e.stateNode},findFiberByHostInstance:Sr.findFiberByHostInstance||$m,findHostInstancesForRefresh:null,scheduleRefresh:null,scheduleRoot:null,setRefreshHandler:null,getCurrentFiber:null,reconcilerVersion:"18.3.1-next-f1338f8080-20240426"};if(typeof __REACT_DEVTOOLS_GLOBAL_HOOK__<"u"){var Do=__REACT_DEVTOOLS_GLOBAL_HOOK__;if(!Do.isDisabled&&Do.supportsFiber)try{Ai=Do.inject(_m),vt=Do}catch{}}We.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED=Cm;We.createPortal=function(e,t){var n=2<arguments.length&&arguments[2]!==void 0?arguments[2]:null;if(!Ds(t))throw Error(E(200));return Sm(e,t,null,n)};We.createRoot=function(e,t){if(!Ds(e))throw Error(E(299));var n=!1,r="",o=op;return t!=null&&(t.unstable_strictMode===!0&&(n=!0),t.identifierPrefix!==void 0&&(r=t.identifierPrefix),t.onRecoverableError!==void 0&&(o=t.onRecoverableError)),t=Is(e,1,!1,null,null,n,!1,r,o),e[Tt]=t.current,eo(e.nodeType===8?e.parentNode:e),new Fs(t)};We.findDOMNode=function(e){if(e==null)return null;if(e.nodeType===1)return e;var t=e._reactInternals;if(t===void 0)throw typeof e.render=="function"?Error(E(188)):(e=Object.keys(e).join(","),Error(E(268,e)));return e=Cd(t),e=e===null?null:e.stateNode,e};We.flushSync=function(e){return wn(e)};We.hydrate=function(e,t,n){if(!Zi(t))throw Error(E(200));return Xi(null,e,t,!0,n)};We.hydrateRoot=function(e,t,n){if(!Ds(e))throw Error(E(405));var r=n!=null&&n.hydratedSources||null,o=!1,i="",l=op;if(n!=null&&(n.unstable_strictMode===!0&&(o=!0),n.identifierPrefix!==void 0&&(i=n.identifierPrefix),n.onRecoverableError!==void 0&&(l=n.onRecoverableError)),t=rp(t,null,e,1,n??null,o,!1,i,l),e[Tt]=t.current,eo(e),r)for(e=0;e<r.length;e++)n=r[e],o=n._getVersion,o=o(n._source),t.mutableSourceEagerHydrationData==null?t.mutableSourceEagerHydrationData=[n,o]:t.mutableSourceEagerHydrationData.push(n,o);return new Qi(t)};We.render=function(e,t,n){if(!Zi(t))throw Error(E(200));return Xi(null,e,t,!1,n)};We.unmountComponentAtNode=function(e){if(!Zi(e))throw Error(E(40));return e._reactRootContainer?(wn(function(){Xi(null,null,e,!1,function(){e._reactRootContainer=null,e[Tt]=null})}),!0):!1};We.unstable_batchedUpdates=Rs;We.unstable_renderSubtreeIntoContainer=function(e,t,n,r){if(!Zi(n))throw Error(E(200));if(e==null||e._reactInternals===void 0)throw Error(E(38));return Xi(e,t,n,!1,r)};We.version="18.3.1-next-f1338f8080-20240426";function ip(){if(!(typeof __REACT_DEVTOOLS_GLOBAL_HOOK__>"u"||typeof __REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE!="function"))try{__REACT_DEVTOOLS_GLOBAL_HOOK__.checkDCE(ip)}catch(e){console.error(e)}}ip(),od.exports=We;var or=od.exports,pc=or;Wl.createRoot=pc.createRoot,Wl.hydrateRoot=pc.hydrateRoot;var Q="-ms-",Dr="-moz-",H="-webkit-",lp="comm",Ji="rule",Hs="decl",Em="@import",jm="@namespace",ap="@keyframes",Tm="@layer",sp=Math.abs,Us=String.fromCharCode,Aa=Object.assign;function Lm(e,t){return pe(e,0)^45?(((t<<2^pe(e,0))<<2^pe(e,1))<<2^pe(e,2))<<2^pe(e,3):0}function up(e){return e.trim()}function $t(e,t){return(e=t.exec(e))?e[0]:e}function M(e,t,n){return e.replace(t,n)}function ti(e,t,n){return e.indexOf(t,n)}function pe(e,t){return e.charCodeAt(t)|0}function kn(e,t,n){return e.slice(t,n)}function lt(e){return e.length}function cp(e){return e.length}function Tr(e,t){return t.push(e),e}function Pm(e,t){return e.map(t).join("")}function hc(e,t){return e.filter(function(n){return!$t(n,t)})}var qi=1,ir=1,dp=0,et=0,ae=0,fr="";function el(e,t,n,r,o,i,l,a){return{value:e,root:t,parent:n,type:r,props:o,children:i,line:qi,column:ir,length:l,return:"",siblings:a}}function Mt(e,t){return Aa(el("",null,null,"",null,null,0,e.siblings),e,{length:-e.length},t)}function En(e){for(;e.root;)e=Mt(e.root,{children:[e]});Tr(e,e.siblings)}function Nm(){return ae}function Om(){return ae=et>0?pe(fr,--et):0,ir--,ae===10&&(ir=1,qi--),ae}function dt(){return ae=et<dp?pe(fr,et++):0,ir++,ae===10&&(ir=1,qi++),ae}function Ht(){return pe(fr,et)}function ni(){return et}function tl(e,t){return kn(fr,e,t)}function uo(e){switch(e){case 0:case 9:case 10:case 13:case 32:return 5;case 33:case 43:case 44:case 47:case 62:case 64:case 126:case 59:case 123:case 125:return 4;case 58:return 3;case 34:case 39:case 40:case 91:return 2;case 41:case 93:return 1}return 0}function Rm(e){return qi=ir=1,dp=lt(fr=e),et=0,[]}function Mm(e){return fr="",e}function Ol(e){return up(tl(et-1,Ia(e===91?e+2:e===40?e+1:e)))}function zm(e){for(;(ae=Ht())&&ae<33;)dt();return uo(e)>2||uo(ae)>3?"":" "}function Am(e,t){for(;--t&&dt()&&!(ae<48||ae>102||ae>57&&ae<65||ae>70&&ae<97););return tl(e,ni()+(t<6&&Ht()==32&&dt()==32))}function Ia(e){for(;dt();)switch(ae){case e:return et;case 34:case 39:e!==34&&e!==39&&Ia(ae);break;case 40:e===41&&Ia(e);break;case 92:dt();break}return et}function Im(e,t){for(;dt()&&e+ae!==57;)if(e+ae===84&&Ht()===47)break;return"/*"+tl(t,et-1)+"*"+Us(e===47?e:dt())}function Bm(e){for(;!uo(Ht());)dt();return tl(e,et)}function Fm(e){return Mm(ri("",null,null,null,[""],e=Rm(e),0,[0],e))}function ri(e,t,n,r,o,i,l,a,s){for(var c=0,m=0,h=l,f=0,w=0,v=0,k=1,_=1,p=1,d=0,g="",S=o,y=i,C=r,b=g;_;)switch(v=d,d=dt()){case 40:if(v!=108&&pe(b,h-1)==58){ti(b+=M(Ol(d),"&","&\f"),"&\f",sp(c?a[c-1]:0))!=-1&&(p=-1);break}case 34:case 39:case 91:b+=Ol(d);break;case 9:case 10:case 13:case 32:b+=zm(v);break;case 92:b+=Am(ni()-1,7);continue;case 47:switch(Ht()){case 42:case 47:Tr(Dm(Im(dt(),ni()),t,n,s),s),(uo(v||1)==5||uo(Ht()||1)==5)&&lt(b)&&kn(b,-1,void 0)!==" "&&(b+=" ");break;default:b+="/"}break;case 123*k:a[c++]=lt(b)*p;case 125*k:case 59:case 0:switch(d){case 0:case 125:_=0;case 59+m:p==-1&&(b=M(b,/\f/g,"")),w>0&&(lt(b)-h||k===0&&v===47)&&Tr(w>32?gc(b+";",r,n,h-1,s):gc(M(b," ","")+";",r,n,h-2,s),s);break;case 59:b+=";";default:if(Tr(C=mc(b,t,n,c,m,o,a,g,S=[],y=[],h,i),i),d===123)if(m===0)ri(b,t,C,C,S,i,h,a,y);else{switch(f){case 99:if(pe(b,3)===110)break;case 108:if(pe(b,2)===97)break;default:m=0;case 100:case 109:case 115:}m?ri(e,C,C,r&&Tr(mc(e,C,C,0,0,o,a,g,o,S=[],h,y),y),o,y,h,a,r?S:y):ri(b,C,C,C,[""],y,0,a,y)}}c=m=w=0,k=p=1,g=b="",h=l;break;case 58:h=1+lt(b),w=v;default:if(k<1){if(d==123)--k;else if(d==125&&k++==0&&Om()==125)continue}switch(b+=Us(d),d*k){case 38:p=m>0?1:(b+="\f",-1);break;case 44:a[c++]=(lt(b)-1)*p,p=1;break;case 64:Ht()===45&&(b+=Ol(dt())),f=Ht(),m=h=lt(g=b+=Bm(ni())),d++;break;case 45:v===45&&lt(b)==2&&(k=0)}}return i}function mc(e,t,n,r,o,i,l,a,s,c,m,h){for(var f=o-1,w=o===0?i:[""],v=cp(w),k=0,_=0,p=0;k<r;++k)for(var d=0,g=kn(e,f+1,f=sp(_=l[k])),S=e;d<v;++d)(S=up(_>0?w[d]+" "+g:M(g,/&\f/g,w[d])))&&(s[p++]=S);return el(e,t,n,o===0?Ji:a,s,c,m,h)}function Dm(e,t,n,r){return el(e,t,n,lp,Us(Nm()),kn(e,2,-2),0,r)}function gc(e,t,n,r,o){return el(e,t,n,Hs,kn(e,0,r),kn(e,r+1,-1),r,o)}function fp(e,t,n){switch(Lm(e,t)){case 5103:return H+"print-"+e+e;case 5737:case 4201:case 3177:case 3433:case 1641:case 4457:case 2921:case 5572:case 6356:case 5844:case 3191:case 6645:case 3005:case 4215:case 6389:case 5109:case 5365:case 5621:case 3829:case 6391:case 5879:case 5623:case 6135:case 4599:return H+e+e;case 4855:return H+e.replace("add","source-over").replace("substract","source-out").replace("intersect","source-in").replace("exclude","xor")+e;case 4789:return Dr+e+e;case 5349:case 4246:case 4810:case 6968:case 2756:return H+e+Dr+e+Q+e+e;case 5936:switch(pe(e,t+11)){case 114:return H+e+Q+M(e,/[svh]\w+-[tblr]{2}/,"tb")+e;case 108:return H+e+Q+M(e,/[svh]\w+-[tblr]{2}/,"tb-rl")+e;case 45:return H+e+Q+M(e,/[svh]\w+-[tblr]{2}/,"lr")+e}case 6828:case 4268:case 2903:return H+e+Q+e+e;case 6165:return H+e+Q+"flex-"+e+e;case 5187:return H+e+M(e,/(\w+).+(:[^]+)/,H+"box-$1$2"+Q+"flex-$1$2")+e;case 5443:return H+e+Q+"flex-item-"+M(e,/flex-|-self/g,"")+($t(e,/flex-|baseline/)?"":Q+"grid-row-"+M(e,/flex-|-self/g,""))+e;case 4675:return H+e+Q+"flex-line-pack"+M(e,/align-content|flex-|-self/g,"")+e;case 5548:return H+e+Q+M(e,"shrink","negative")+e;case 5292:return H+e+Q+M(e,"basis","preferred-size")+e;case 6060:return H+"box-"+M(e,"-grow","")+H+e+Q+M(e,"grow","positive")+e;case 4554:return H+M(e,/([^-])(transform)/g,"$1"+H+"$2")+e;case 6187:return M(M(M(e,/(zoom-|grab)/,H+"$1"),/(image-set)/,H+"$1"),e,"")+e;case 5495:case 3959:return M(e,/(image-set\([^]*)/,H+"$1$`$1");case 4968:return M(M(e,/(.+:)(flex-)?(.*)/,H+"box-pack:$3"+Q+"flex-pack:$3"),/space-between/,"justify")+H+e+e;case 4200:if(!$t(e,/flex-|baseline/))return Q+"grid-column-align"+kn(e,t)+e;break;case 2592:case 3360:return Q+M(e,"template-","")+e;case 4384:case 3616:return n&&n.some(function(r,o){return t=o,$t(r.props,/grid-\w+-end/)})?~ti(e+(n=n[t].value),"span",0)?e:Q+M(e,"-start","")+e+Q+"grid-row-span:"+(~ti(n,"span",0)?$t(n,/\d+/):+$t(n,/\d+/)-+$t(e,/\d+/))+";":Q+M(e,"-start","")+e;case 4896:case 4128:return n&&n.some(function(r){return $t(r.props,/grid-\w+-start/)})?e:Q+M(M(e,"-end","-span"),"span ","")+e;case 4095:case 3583:case 4068:case 2532:return M(e,/(.+)-inline(.+)/,H+"$1$2")+e;case 8116:case 7059:case 5753:case 5535:case 5445:case 5701:case 4933:case 4677:case 5533:case 5789:case 5021:case 4765:if(lt(e)-1-t>6)switch(pe(e,t+1)){case 109:if(pe(e,t+4)!==45)break;case 102:return M(e,/(.+:)(.+)-([^]+)/,"$1"+H+"$2-$3$1"+Dr+(pe(e,t+3)==108?"$3":"$2-$3"))+e;case 115:return~ti(e,"stretch",0)?fp(M(e,"stretch","fill-available"),t,n)+e:e}break;case 5152:case 5920:return M(e,/(.+?):(\d+)(\s*\/\s*(span)?\s*(\d+))?(.*)/,function(r,o,i,l,a,s,c){return Q+o+":"+i+c+(l?Q+o+"-span:"+(a?s:+s-+i)+c:"")+e});case 4949:if(pe(e,t+6)===121)return M(e,":",":"+H)+e;break;case 6444:switch(pe(e,pe(e,14)===45?18:11)){case 120:return M(e,/(.+:)([^;\s!]+)(;|(\s+)?!.+)?/,"$1"+H+(pe(e,14)===45?"inline-":"")+"box$3$1"+H+"$2$3$1"+Q+"$2box$3")+e;case 100:return M(e,":",":"+Q)+e}break;case 5719:case 2647:case 2135:case 3927:case 2391:return M(e,"scroll-","scroll-snap-")+e}return e}function Pi(e,t){for(var n="",r=0;r<e.length;r++)n+=t(e[r],r,e,t)||"";return n}function Hm(e,t,n,r){switch(e.type){case Tm:if(e.children.length)break;case Em:case jm:case Hs:return e.return=e.return||e.value;case lp:return"";case ap:return e.return=e.value+"{"+Pi(e.children,r)+"}";case Ji:if(!lt(e.value=e.props.join(",")))return""}return lt(n=Pi(e.children,r))?e.return=e.value+"{"+n+"}":""}function Um(e){var t=cp(e);return function(n,r,o,i){for(var l="",a=0;a<t;a++)l+=e[a](n,r,o,i)||"";return l}}function Wm(e){return function(t){t.root||(t=t.return)&&e(t)}}function Vm(e,t,n,r){if(e.length>-1&&!e.return)switch(e.type){case Hs:e.return=fp(e.value,e.length,n);return;case ap:return Pi([Mt(e,{value:M(e.value,"@","@"+H)})],r);case Ji:if(e.length)return Pm(n=e.props,function(o){switch($t(o,r=/(::plac\w+|:read-\w+)/)){case":read-only":case":read-write":En(Mt(e,{props:[M(o,/:(read-\w+)/,":"+Dr+"$1")]})),En(Mt(e,{props:[o]})),Aa(e,{props:hc(n,r)});break;case"::placeholder":En(Mt(e,{props:[M(o,/:(plac\w+)/,":"+H+"input-$1")]})),En(Mt(e,{props:[M(o,/:(plac\w+)/,":"+Dr+"$1")]})),En(Mt(e,{props:[M(o,/:(plac\w+)/,Q+"input-$1")]})),En(Mt(e,{props:[o]})),Aa(e,{props:hc(n,r)});break}return""})}}var Zn={},Rl,Ml;const lr=typeof process<"u"&&Zn!==void 0&&(Zn.REACT_APP_SC_ATTR||Zn.SC_ATTR)||"data-styled",pp="active",hp="data-styled-version",nl="6.4.2",Ws=`/*!sc*/
`,Hr=typeof window<"u"&&typeof document<"u";function yc(e){if(typeof process<"u"&&Zn!==void 0){const t=Zn[e];if(t!==void 0&&t!=="")return t!=="false"}}const Gm=!!(typeof SC_DISABLE_SPEEDY=="boolean"?SC_DISABLE_SPEEDY:(Ml=(Rl=yc("REACT_APP_SC_DISABLE_SPEEDY"))!==null&&Rl!==void 0?Rl:yc("SC_DISABLE_SPEEDY"))!==null&&Ml!==void 0?Ml:typeof process<"u"&&Zn!==void 0&&!1),mp="sc-keyframes-",Km={};function yo(e,...t){return new Error(`An error occurred. See https://github.com/styled-components/styled-components/blob/main/packages/styled-components/src/utils/errors.md#${e} for more information.${t.length>0?` Args: ${t.join(", ")}`:""}`)}let oi=new Map,Ni=new Map,ii=1;const Lr=e=>{if(oi.has(e))return oi.get(e);for(;Ni.has(ii);)ii++;const t=ii++;return oi.set(e,t),Ni.set(t,e),t},Ym=e=>Ni.get(e),Qm=(e,t)=>{ii=t+1,oi.set(e,t),Ni.set(t,e)},Vs=Object.freeze([]),ar=Object.freeze({});function gp(e,t,n=ar){return e.theme!==n.theme&&e.theme||t||n.theme}const Zm=/[!"#$%&'()*+,./:;<=>?@[\\\]^`{|}~-]+/g,Xm=/(^-|-$)/g;function yp(e){return e.replace(Zm,"-").replace(Xm,"")}const Jm=/(a)(d)/gi,xc=e=>String.fromCharCode(e+(e>25?39:97));function Gs(e){let t,n="";for(t=Math.abs(e);t>52;t=t/52|0)n=xc(t%52)+n;return(xc(t%52)+n).replace(Jm,"$1-$2")}const Ba=5381,hn=(e,t)=>{let n=t.length;for(;n;)e=33*e^t.charCodeAt(--n);return e},xp=e=>hn(Ba,e);function Ks(e){return Gs(xp(e)>>>0)}function qm(e){return e.displayName||e.name||"Component"}function Fa(e){return typeof e=="string"&&!0}function e1(e){return Fa(e)?`styled.${e}`:`Styled(${qm(e)})`}const vp=Symbol.for("react.memo"),t1=Symbol.for("react.forward_ref"),n1={contextType:!0,defaultProps:!0,displayName:!0,getDerivedStateFromError:!0,getDerivedStateFromProps:!0,propTypes:!0,type:!0},r1={name:!0,length:!0,prototype:!0,caller:!0,callee:!0,arguments:!0,arity:!0},wp={$$typeof:!0,compare:!0,defaultProps:!0,displayName:!0,propTypes:!0,type:!0},o1={[t1]:{$$typeof:!0,render:!0,defaultProps:!0,displayName:!0,propTypes:!0},[vp]:wp};function vc(e){return("type"in(t=e)&&t.type.$$typeof)===vp?wp:"$$typeof"in e?o1[e.$$typeof]:n1;var t}const i1=Object.defineProperty,l1=Object.getOwnPropertyNames,a1=Object.getOwnPropertySymbols,s1=Object.getOwnPropertyDescriptor,u1=Object.getPrototypeOf,c1=Object.prototype;function kp(e,t,n){if(typeof t!="string"){const r=u1(t);r&&r!==c1&&kp(e,r,n);const o=l1(t).concat(a1(t)),i=vc(e),l=vc(t);for(let a=0;a<o.length;++a){const s=o[a];if(!(s in r1||n&&n[s]||l&&s in l||i&&s in i)){const c=s1(t,s);try{i1(e,s,c)}catch{}}}}return e}function xo(e){return typeof e=="function"}const d1=Symbol.for("react.forward_ref");function Ys(e){return e!=null&&(typeof e=="object"||typeof e=="function")&&e.$$typeof===d1&&"styledComponentId"in e}function Pr(e,t){return e&&t?e+" "+t:e||t||""}function Oi(e,t){return e.join("")}function co(e){return e!==null&&typeof e=="object"&&e.constructor.name===Object.name&&!("props"in e&&e.$$typeof)}function Da(e,t,n=!1){if(!n&&!co(e)&&!Array.isArray(e))return t;if(Array.isArray(t))for(let r=0;r<t.length;r++)e[r]=Da(e[r],t[r]);else if(co(t))for(const r in t)e[r]=Da(e[r],t[r]);return e}function Qs(e,t){Object.defineProperty(e,"toString",{value:t})}const f1=class{constructor(e){this.groupSizes=new Uint32Array(512),this.length=512,this.tag=e,this._cGroup=0,this._cIndex=0}indexOfGroup(e){if(e===this._cGroup)return this._cIndex;let t=this._cIndex;if(e>this._cGroup)for(let n=this._cGroup;n<e;n++)t+=this.groupSizes[n];else for(let n=this._cGroup-1;n>=e;n--)t-=this.groupSizes[n];return this._cGroup=e,this._cIndex=t,t}insertRules(e,t){if(e>=this.groupSizes.length){const o=this.groupSizes,i=o.length;let l=i;for(;e>=l;)if(l<<=1,l<0)throw yo(16,`${e}`);this.groupSizes=new Uint32Array(l),this.groupSizes.set(o),this.length=l;for(let a=i;a<l;a++)this.groupSizes[a]=0}let n=this.indexOfGroup(e+1),r=0;for(let o=0,i=t.length;o<i;o++)this.tag.insertRule(n,t[o])&&(this.groupSizes[e]++,n++,r++);r>0&&this._cGroup>e&&(this._cIndex+=r)}clearGroup(e){if(e<this.length){const t=this.groupSizes[e],n=this.indexOfGroup(e),r=n+t;this.groupSizes[e]=0;for(let o=n;o<r;o++)this.tag.deleteRule(n);t>0&&this._cGroup>e&&(this._cIndex-=t)}}getGroup(e){let t="";if(e>=this.length||this.groupSizes[e]===0)return t;const n=this.groupSizes[e],r=this.indexOfGroup(e),o=r+n;for(let i=r;i<o;i++)t+=this.tag.getRule(i)+Ws;return t}},p1=`style[${lr}][${hp}="${nl}"]`,h1=new RegExp(`^${lr}\\.g(\\d+)\\[id="([\\w\\d-]+)"\\].*?"([^"]*)`),wc=e=>typeof ShadowRoot<"u"&&e instanceof ShadowRoot||"host"in e&&e.nodeType===11,Ha=e=>{if(!e)return document;if(wc(e))return e;if("getRootNode"in e){const t=e.getRootNode();if(wc(t))return t}return document},m1=(e,t,n)=>{const r=n.split(",");let o;for(let i=0,l=r.length;i<l;i++)(o=r[i])&&e.registerName(t,o)},g1=(e,t)=>{var n;const r=((n=t.textContent)!==null&&n!==void 0?n:"").split(Ws),o=[];for(let i=0,l=r.length;i<l;i++){const a=r[i].trim();if(!a)continue;const s=a.match(h1);if(s){const c=0|parseInt(s[1],10),m=s[2];c!==0&&(Qm(m,c),m1(e,m,s[3]),e.getTag().insertRules(c,o)),o.length=0}else o.push(a)}},zl=e=>{const t=Ha(e.options.target).querySelectorAll(p1);for(let n=0,r=t.length;n<r;n++){const o=t[n];o&&o.getAttribute(lr)!==pp&&(g1(e,o),o.parentNode&&o.parentNode.removeChild(o))}};let $r=!1;function y1(){if($r!==!1)return $r;if(typeof document<"u"){const e=document.head.querySelector('meta[property="csp-nonce"]');if(e)return $r=e.nonce||e.getAttribute("content")||void 0;const t=document.head.querySelector('meta[name="sc-nonce"]');if(t)return $r=t.getAttribute("content")||void 0}return $r=typeof __webpack_nonce__<"u"?__webpack_nonce__:void 0}const Sp=(e,t)=>{const n=document.head,r=e||n,o=document.createElement("style"),i=(s=>{const c=Array.from(s.querySelectorAll(`style[${lr}]`));return c[c.length-1]})(r),l=i!==void 0?i.nextSibling:null;o.setAttribute(lr,pp),o.setAttribute(hp,nl);const a=t||y1();return a&&o.setAttribute("nonce",a),r.insertBefore(o,l),o},x1=class{constructor(e,t){this.element=Sp(e,t),this.element.appendChild(document.createTextNode("")),this.sheet=(n=>{var r;if(n.sheet)return n.sheet;const o=(r=n.getRootNode().styleSheets)!==null&&r!==void 0?r:document.styleSheets;for(let i=0,l=o.length;i<l;i++){const a=o[i];if(a.ownerNode===n)return a}throw yo(17)})(this.element),this.length=0}insertRule(e,t){try{return this.sheet.insertRule(t,e),this.length++,!0}catch{return!1}}deleteRule(e){this.sheet.deleteRule(e),this.length--}getRule(e){const t=this.sheet.cssRules[e];return t&&t.cssText?t.cssText:""}},v1=class{constructor(e,t){this.element=Sp(e,t),this.nodes=this.element.childNodes,this.length=0}insertRule(e,t){if(e<=this.length&&e>=0){const n=document.createTextNode(t);return this.element.insertBefore(n,this.nodes[e]||null),this.length++,!0}return!1}deleteRule(e){this.element.removeChild(this.nodes[e]),this.length--}getRule(e){return e<this.length?this.nodes[e].textContent:""}};let kc=Hr;const w1={isServer:!Hr,useCSSOMInjection:!Gm};class vo{static registerId(t){return Lr(t)}constructor(t=ar,n={},r){this.options=Object.assign(Object.assign({},w1),t),this.gs=n,this.keyframeIds=new Set,this.names=new Map(r),this.server=!!t.isServer,!this.server&&Hr&&kc&&(kc=!1,zl(this)),Qs(this,()=>(o=>{const i=o.getTag(),{length:l}=i;let a="";for(let s=0;s<l;s++){const c=Ym(s);if(c===void 0)continue;const m=o.names.get(c);if(m===void 0||!m.size)continue;const h=i.getGroup(s);if(h.length===0)continue;const f=lr+".g"+s+'[id="'+c+'"]';let w="";for(const v of m)v.length>0&&(w+=v+",");a+=h+f+'{content:"'+w+'"}'+Ws}return a})(this))}rehydrate(){!this.server&&Hr&&zl(this)}reconstructWithOptions(t,n=!0){const r=new vo(Object.assign(Object.assign({},this.options),t),this.gs,n&&this.names||void 0);return r.keyframeIds=new Set(this.keyframeIds),!this.server&&Hr&&t.target!==this.options.target&&Ha(this.options.target)!==Ha(t.target)&&zl(r),r}allocateGSInstance(t){return this.gs[t]=(this.gs[t]||0)+1}getTag(){return this.tag||(this.tag=(t=(({useCSSOMInjection:n,target:r,nonce:o})=>n?new x1(r,o):new v1(r,o))(this.options),new f1(t)));var t}hasNameForId(t,n){var r,o;return(o=(r=this.names.get(t))===null||r===void 0?void 0:r.has(n))!==null&&o!==void 0&&o}registerName(t,n){Lr(t),t.startsWith(mp)&&this.keyframeIds.add(t);const r=this.names.get(t);r?r.add(n):this.names.set(t,new Set([n]))}insertRules(t,n,r){this.registerName(t,n),this.getTag().insertRules(Lr(t),r)}clearNames(t){this.names.has(t)&&this.names.get(t).clear()}clearRules(t){this.getTag().clearGroup(Lr(t)),this.clearNames(t)}clearTag(){this.tag=void 0}}const $p=new WeakSet,k1={animationIterationCount:1,aspectRatio:1,borderImageOutset:1,borderImageSlice:1,borderImageWidth:1,columnCount:1,columns:1,flex:1,flexGrow:1,flexShrink:1,gridRow:1,gridRowEnd:1,gridRowSpan:1,gridRowStart:1,gridColumn:1,gridColumnEnd:1,gridColumnSpan:1,gridColumnStart:1,fontWeight:1,lineHeight:1,opacity:1,order:1,orphans:1,scale:1,tabSize:1,widows:1,zIndex:1,zoom:1,WebkitLineClamp:1,fillOpacity:1,floodOpacity:1,stopOpacity:1,strokeDasharray:1,strokeDashoffset:1,strokeMiterlimit:1,strokeOpacity:1,strokeWidth:1};function S1(e,t){return t==null||typeof t=="boolean"||t===""?"":typeof t!="number"||t===0||e in k1||e.startsWith("--")?String(t).trim():t+"px"}const sn=47;function Sc(e){if(e.charCodeAt(0)===45&&e.charCodeAt(1)===45)return e;let t="";for(let n=0;n<e.length;n++){const r=e.charCodeAt(n);t+=r>=65&&r<=90?"-"+String.fromCharCode(r+32):e[n]}return t.startsWith("ms-")?"-"+t:t}const bp=Symbol.for("sc-keyframes");function $1(e){return typeof e=="object"&&e!==null&&bp in e}function Cp(e){return xo(e)&&!(e.prototype&&e.prototype.isReactComponent)}const _p=e=>e==null||e===!1||e==="",b1=Symbol.for("react.client.reference");function $c(e){return e.$$typeof===b1}function Ep(e,t){for(const n in e){const r=e[n];e.hasOwnProperty(n)&&!_p(r)&&(Array.isArray(r)&&$p.has(r)||xo(r)?t.push(Sc(n)+":",r,";"):co(r)?(t.push(n+" {"),Ep(r,t),t.push("}")):t.push(Sc(n)+": "+S1(n,r)+";"))}}function Jt(e,t,n,r,o=[]){if(_p(e))return o;const i=typeof e;if(i==="string")return o.push(e),o;if(i==="function"){if($c(e))return o;if(Cp(e)&&t){const l=e(t);return Jt(l,t,n,r,o)}return o.push(e),o}if(Array.isArray(e)){for(let l=0;l<e.length;l++)Jt(e[l],t,n,r,o);return o}return Ys(e)?(o.push(`.${e.styledComponentId}`),o):$1(e)?(n?(e.inject(n,r),o.push(e.getName(r))):o.push(e),o):$c(e)?o:co(e)?e.toString!==Object.prototype.toString?(o.push(e.toString()),o):(Ep(e,o),o):(o.push(e.toString()),o)}const C1=xp(nl);class _1{constructor(t,n,r){this.rules=t,this.componentId=n,this.baseHash=hn(C1,n),this.baseStyle=r,vo.registerId(n)}generateAndInjectStyles(t,n,r){let o=this.baseStyle?this.baseStyle.generateAndInjectStyles(t,n,r):"";{let i="";for(let l=0;l<this.rules.length;l++){const a=this.rules[l];if(typeof a=="string")i+=a;else if(a)if(Cp(a)){const s=a(t);typeof s=="string"?i+=s:s!=null&&s!==!1&&(i+=Oi(Jt(s,t,n,r)))}else i+=Oi(Jt(a,t,n,r))}if(i){this.dynamicNameCache||(this.dynamicNameCache=new Map);const l=r.hash?r.hash+i:i;let a=this.dynamicNameCache.get(l);if(!a){if(a=Gs(hn(hn(this.baseHash,r.hash),i)>>>0),this.dynamicNameCache.size>=200){const s=this.dynamicNameCache.keys().next().value;s!==void 0&&this.dynamicNameCache.delete(s)}this.dynamicNameCache.set(l,a)}if(!n.hasNameForId(this.componentId,a)){const s=r(i,"."+a,void 0,this.componentId);n.insertRules(this.componentId,a,s)}o=Pr(o,a)}}return o}}const E1=/&/g;function jp(e,t){let n=0;for(;--t>=0&&e.charCodeAt(t)===92;)n++;return!(1&~n)}function Al(e){const t=e.length;let n="",r=0,o=0,i=0,l=!1,a=!1;for(let s=0;s<t;s++){const c=e.charCodeAt(s);if(i!==0||l||c!==sn||e.charCodeAt(s+1)!==42)if(l)c===42&&e.charCodeAt(s+1)===sn&&(l=!1,s++);else if(c!==34&&c!==39||jp(e,s)){if(i===0)if(c===123)o++;else if(c===125){if(o--,o<0){a=!0;let m=s+1;for(;m<t;){const h=e.charCodeAt(m);if(h===59||h===10)break;m++}m<t&&e.charCodeAt(m)===59&&m++,o=0,s=m-1,r=m;continue}o===0&&(n+=e.substring(r,s+1),r=s+1)}else c===59&&o===0&&(n+=e.substring(r,s+1),r=s+1)}else i===0?i=c:i===c&&(i=0);else l=!0,s++}return a||o!==0||i!==0?(r<t&&o===0&&i===0&&(n+=e.substring(r)),n):e}function Tp(e,t){const n=t+" ",r=","+n;for(let o=0;o<e.length;o++){const i=e[o];if(i.type==="rule"){i.value=(n+i.value).replaceAll(",",r);const l=i.props,a=[];for(let s=0;s<l.length;s++)a[s]=n+l[s];i.props=a}Array.isArray(i.children)&&i.type!=="@keyframes"&&Tp(i.children,t)}return e}function j1({options:e=ar,plugins:t=Vs}=ar){let n,r,o;const i=(f,w,v)=>v.startsWith(r)&&v.endsWith(r)&&v.replaceAll(r,"").length>0?`.${n}`:f,l=t.slice();l.push(f=>{f.type===Ji&&f.value.includes("&")&&(o||(o=new RegExp(`\\${r}\\b`,"g")),f.props[0]=f.props[0].replace(E1,r).replace(o,i))}),e.prefix&&l.push(Vm),l.push(Hm);let a=[];const s=Um(l.concat(Wm(f=>a.push(f)))),c=(f,w="",v="",k="&")=>{n=k,r=w,o=void 0;const _=function(d){const g=d.indexOf("//")!==-1,S=d.indexOf("}")!==-1;if(!g&&!S)return d;if(!g)return Al(d);const y=d.length;let C="",b=0,$=0,R=0,O=0,D=0,W=!1;for(;$<y;){const z=d.charCodeAt($);if(z!==34&&z!==39||jp(d,$))if(R===0)if(z===sn&&$+1<y&&d.charCodeAt($+1)===42){for($+=2;$+1<y&&(d.charCodeAt($)!==42||d.charCodeAt($+1)!==sn);)$++;$+=2}else if(z!==40)if(z!==41)if(O>0)$++;else if(z===42&&$+1<y&&d.charCodeAt($+1)===sn)C+=d.substring(b,$),$+=2,b=$,W=!0;else if(z===sn&&$+1<y&&d.charCodeAt($+1)===sn){for(C+=d.substring(b,$);$<y&&d.charCodeAt($)!==10;)$++;b=$,W=!0}else z===123?D++:z===125&&D--,$++;else O>0&&O--,$++;else O++,$++;else $++;else R===0?R=z:R===z&&(R=0),$++}return W?(b<y&&(C+=d.substring(b)),D===0?C:Al(C)):D===0?d:Al(d)}(f);let p=Fm(v||w?v+" "+w+" { "+_+" }":_);return e.namespace&&(p=Tp(p,e.namespace)),a=[],Pi(p,s),a},m=e;let h=Ba;for(let f=0;f<t.length;f++)t[f].name||yo(15),h=hn(h,t[f].name);return m?.namespace&&(h=hn(h,m.namespace)),m?.prefix&&(h=hn(h,"p")),c.hash=h!==Ba?h.toString():"",c}const T1=new vo,Ua=j1(),Lp=Fe.createContext({shouldForwardProp:void 0,styleSheet:T1,stylis:Ua,stylisPlugins:void 0});Lp.Consumer;function Pp(){return Fe.useContext(Lp)}const Zs=Fe.createContext(void 0);Zs.Consumer;const bc=Object.prototype.hasOwnProperty,Il={};function L1(e,t){const n=typeof e!="string"?"sc":yp(e);Il[n]=(Il[n]||0)+1;const r=n+"-"+Ks(nl+n+Il[n]);return t?t+"-"+r:r}function P1(e,t,n){const r=Ys(e),o=e,i=!Fa(e),{attrs:l=Vs,componentId:a=L1(t.displayName,t.parentComponentId),displayName:s=e1(e)}=t,c=t.displayName&&t.componentId?yp(t.displayName)+"-"+t.componentId:t.componentId||a,m=r&&o.attrs?o.attrs.concat(l).filter(Boolean):l;let{shouldForwardProp:h}=t;if(r&&o.shouldForwardProp){const k=o.shouldForwardProp;if(t.shouldForwardProp){const _=t.shouldForwardProp;h=(p,d)=>k(p,d)&&_(p,d)}else h=k}const f=new _1(n,c,r?o.componentStyle:void 0);function w(k,_){return function(p,d,g){const{attrs:S,componentStyle:y,defaultProps:C,foldedComponentIds:b,styledComponentId:$,target:R}=p,O=Fe.useContext(Zs),D=Pp(),W=p.shouldForwardProp||D.shouldForwardProp,z=gp(d,O,C)||ar;let Ae,ht;{const P=Fe.useRef(null),N=P.current;if(N!==null&&N[1]===z&&N[2]===D.styleSheet&&N[3]===D.stylis&&N[7]===y&&function(G,F,de){const ne=G,ie=F;let Ie=0;for(const Ke in ie)if(bc.call(ie,Ke)&&(Ie++,ne[Ke]!==ie[Ke]))return!1;return Ie===de}(N[0],d,N[4]))Ae=N[5],ht=N[6];else{Ae=function(F,de,ne){const ie=Object.assign(Object.assign({},de),{className:void 0,theme:ne}),Ie=F.length>1;for(let Ke=0;Ke<F.length;Ke++){const ll=F[Ke],bo=xo(ll)?ll(Ie?Object.assign({},ie):ie):ll;for(const Ot in bo)Ot==="className"?ie.className=Pr(ie.className,bo[Ot]):Ot==="style"?ie.style=Object.assign(Object.assign({},ie.style),bo[Ot]):Ot in de&&de[Ot]===void 0||(ie[Ot]=bo[Ot])}return"className"in de&&typeof de.className=="string"&&(ie.className=Pr(ie.className,de.className)),ie}(S,d,z),ht=function(F,de,ne,ie){return F.generateAndInjectStyles(de,ne,ie)}(y,Ae,D.styleSheet,D.stylis);let G=0;for(const F in d)bc.call(d,F)&&G++;P.current=[d,z,D.styleSheet,D.stylis,G,Ae,ht,y]}}const _e=Ae.as||R,ce=function(P,N,G,F){const de={};for(const ne in P)P[ne]===void 0||ne[0]==="$"||ne==="as"||ne==="theme"&&P.theme===G||(ne==="forwardedAs"?de.as=P.forwardedAs:F&&!F(ne,N)||(de[ne]=P[ne]));return de}(Ae,_e,z,W);let T=Pr(b,$);return ht&&(T+=" "+ht),Ae.className&&(T+=" "+Ae.className),ce[Fa(_e)&&_e.includes("-")?"class":"className"]=T,g&&(ce.ref=g),j.createElement(_e,ce)}(v,k,_)}w.displayName=s;let v=Fe.forwardRef(w);return v.attrs=m,v.componentStyle=f,v.displayName=s,v.shouldForwardProp=h,v.foldedComponentIds=r?Pr(o.foldedComponentIds,o.styledComponentId):"",v.styledComponentId=c,v.target=r?o.target:e,Object.defineProperty(v,"defaultProps",{get(){return this._foldedDefaultProps},set(k){this._foldedDefaultProps=r?function(_,...p){for(const d of p)Da(_,d,!0);return _}({},o.defaultProps,k):k}}),Qs(v,()=>`.${v.styledComponentId}`),i&&kp(v,e,{attrs:!0,componentStyle:!0,displayName:!0,foldedComponentIds:!0,shouldForwardProp:!0,styledComponentId:!0,target:!0}),v}var N1=new Set(["a","abbr","address","area","article","aside","audio","b","bdi","bdo","blockquote","body","button","br","canvas","caption","cite","code","col","colgroup","data","datalist","dd","del","details","dfn","dialog","div","dl","dt","em","embed","fieldset","figcaption","figure","footer","form","h1","h2","h3","h4","h5","h6","header","hgroup","hr","html","i","iframe","img","input","ins","kbd","label","legend","li","main","map","mark","menu","meter","nav","object","ol","optgroup","option","output","p","picture","pre","progress","q","rp","rt","ruby","s","samp","search","section","select","slot","small","span","strong","sub","summary","sup","table","tbody","td","template","textarea","tfoot","th","thead","time","tr","u","ul","var","video","wbr","circle","clipPath","defs","ellipse","feBlend","feColorMatrix","feComponentTransfer","feComposite","feConvolveMatrix","feDiffuseLighting","feDisplacementMap","feDistantLight","feDropShadow","feFlood","feFuncA","feFuncB","feFuncG","feFuncR","feGaussianBlur","feImage","feMerge","feMergeNode","feMorphology","feOffset","fePointLight","feSpecularLighting","feSpotLight","feTile","feTurbulence","filter","foreignObject","g","image","line","linearGradient","marker","mask","path","pattern","polygon","polyline","radialGradient","rect","stop","svg","switch","symbol","text","textPath","tspan","use"]);function Cc(e,t){const n=[e[0]];for(let r=0,o=t.length;r<o;r+=1)n.push(t[r],e[r+1]);return n}const _c=e=>($p.add(e),e);function Xs(e,...t){if(xo(e)||co(e))return _c(Jt(Cc(Vs,[e,...t])));const n=e;return t.length===0&&n.length===1&&typeof n[0]=="string"?Jt(n):_c(Jt(Cc(n,t)))}function Wa(e,t,n=ar){if(!t)throw yo(1,t);const r=(o,...i)=>e(t,n,Xs(o,...i));return r.attrs=o=>Wa(e,t,Object.assign(Object.assign({},n),{attrs:Array.prototype.concat(n.attrs,o).filter(Boolean)})),r.withConfig=o=>Wa(e,t,Object.assign(Object.assign({},n),o)),r}const Np=e=>Wa(P1,e),x=Np;N1.forEach(e=>{x[e]=Np(e)});class O1{constructor(t,n){this.instanceRules=new Map,this.rules=t,this.componentId=n,this.isStatic=function(r){for(let o=0;o<r.length;o+=1){const i=r[o];if(xo(i)&&!Ys(i))return!1}return!0}(t),vo.registerId(this.componentId)}removeStyles(t,n){this.instanceRules.delete(t),this.rebuildGroup(n)}renderStyles(t,n,r,o){const i=this.componentId;if(this.isStatic){if(r.hasNameForId(i,i+t))this.instanceRules.has(t)||this.computeRules(t,n,r,o);else{const a=this.computeRules(t,n,r,o);r.insertRules(i,a.name,a.rules)}return}const l=this.instanceRules.get(t);if(this.computeRules(t,n,r,o),!r.server&&l){const a=l.rules,s=this.instanceRules.get(t).rules;if(a.length===s.length){let c=!0;for(let m=0;m<a.length;m++)if(a[m]!==s[m]){c=!1;break}if(c)return}}this.rebuildGroup(r)}computeRules(t,n,r,o){const i=Oi(Jt(this.rules,n,r,o)),l={name:this.componentId+t,rules:o(i,"")};return this.instanceRules.set(t,l),l}rebuildGroup(t){const n=this.componentId;t.clearRules(n);for(const r of this.instanceRules.values())t.insertRules(n,r.name,r.rules)}}function R1(e,...t){const n=Xs(e,...t),r=`sc-global-${Ks(JSON.stringify(n))}`,o=new O1(n,r),i=a=>{const s=Pp(),c=Fe.useContext(Zs);let m;{const h=Fe.useRef(null);h.current===null&&(h.current=s.styleSheet.allocateGSInstance(r)),m=h.current}s.styleSheet.server&&l(m,a,s.styleSheet,c,s.stylis);{const h=o.isStatic?[m,s.styleSheet,o]:[m,a,s.styleSheet,c,s.stylis,o],f=Fe.useRef(o);Fe.useLayoutEffect(()=>{s.styleSheet.server||(f.current!==o&&(s.styleSheet.clearRules(r),f.current=o),l(m,a,s.styleSheet,c,s.stylis))},h),Fe.useLayoutEffect(()=>()=>{s.styleSheet.server||o.removeStyles(m,s.styleSheet)},[m,s.styleSheet,o])}return s.styleSheet.server&&o.instanceRules.delete(m),null};function l(a,s,c,m,h){if(o.isStatic)o.renderStyles(a,Km,c,h);else{const f=Object.assign(Object.assign({},s),{theme:gp(s,m,i.defaultProps)});o.renderStyles(a,f,c,h)}}return Fe.memo(i)}var Op;class M1{constructor(t,n){this[Op]=!0,this.inject=(r,o=Ua)=>{const i=this.getName(o);if(!r.hasNameForId(this.id,i)){const l=o(this.rules,i,"@keyframes");r.insertRules(this.id,i,l)}},this.name=t,this.id=mp+t,this.rules=n,Lr(this.id),Qs(this,()=>{throw yo(12,String(this.name))})}getName(t=Ua){return t.hash?this.name+Gs(+t.hash>>>0):this.name}}function Js(e,...t){const n=Oi(Xs(e,...t)),r=Ks(n);return new M1(r,n)}Op=bp;const le={color:{accent:"var(--accent)",accentGlow:"rgba(var(--accent-rgb), 0.44)",accentSoft:"rgba(var(--accent-rgb), 0.28)",accentFaint:"rgba(var(--accent-rgb), 0.03)",buttonFrom:"var(--accent-strong)",buttonTo:"var(--accent-deep)",text:"#ffffff",textLabel:"#d7d7d7",textMuted:"rgba(255, 255, 255, 0.55)",textFaint:"rgba(255, 255, 255, 0.40)",textDim:"rgba(255, 255, 255, 0.32)",railTop:"rgb(27, 27, 27)",railBottom:"rgb(10, 10, 10)",surface03:"rgba(217, 217, 217, 0.03)",surface05:"rgba(217, 217, 217, 0.05)",surface15:"rgba(217, 217, 217, 0.15)",surface20:"rgba(217, 217, 217, 0.20)",surfaceGrey:"rgba(115, 115, 115, 0.28)",surfaceGreyFaint:"rgba(115, 115, 115, 0.10)",border:"rgba(255, 255, 255, 0.41)",borderSoft:"rgba(255, 255, 255, 0.14)",divider:"rgba(217, 217, 217, 0.13)",scrollTrack:"rgba(255, 255, 255, 0.07)",controlBar:"rgba(20, 20, 20, 0.74)",controlBarBorder:"rgba(255, 255, 255, 0.11)",controlSep:"rgba(217, 217, 217, 0.09)"},font:{display:"'Bebas Neue', system-ui, sans-serif",body:"'Chakra Petch', system-ui, sans-serif"},radius:{sm:"4px",md:"6px",lg:"8px",xl:"13px",pill:"999px"},shadow:{accentGlow:"0 0 66px 4px rgba(var(--accent-rgb), 0.44)",accentGlowSoft:"0 0 40px 2px rgba(var(--accent-rgb), 0.40)",buttonGlow:"0 0 61.7px 0 rgba(var(--accent-strong-rgb), 0.25)"},panelOpacity:.93,layout:{stageWidth:1920,stageHeight:1080,railWidth:162,panelX:162,panelWidth:473,contentPad:37,contentWidth:399}},Va="#ff454b";function z1(e){const t=e.replace("#","").trim(),n=t.length===3?t.split("").map(r=>r+r).join(""):t;return[parseInt(n.slice(0,2),16),parseInt(n.slice(2,4),16),parseInt(n.slice(4,6),16)]}const Ur=e=>Math.max(0,Math.min(255,Math.round(e))),Ec=e=>e.map(Ur).join(", "),jn=e=>"#"+e.map(t=>Ur(t).toString(16).padStart(2,"0")).join(""),Tn=(e,t)=>[e[0]*t,e[1]*t,e[2]*t];function Rp(e){const t=z1(e),n=Tn(t,.84),r=Tn(t,.62);return{"--accent":e,"--accent-rgb":Ec(t),"--accent-r":String(Ur(t[0])),"--accent-g":String(Ur(t[1])),"--accent-b":String(Ur(t[2])),"--accent-strong":jn(n),"--accent-strong-rgb":Ec(n),"--accent-deep":jn(r),"--accent-badge":`radial-gradient(circle at 50% 32%, ${jn(Tn(t,.84))} 0%, ${jn(Tn(t,.62))} 50%, ${jn(Tn(t,.5))} 75%, ${jn(Tn(t,.39))} 100%)`}}const A1=Rp(Va);function qs(e){const t=document.documentElement;for(const[n,r]of Object.entries(Rp(e)))t.style.setProperty(n,r)}const I1=Object.entries(A1).map(([e,t])=>`${e}: ${t};`).join(`
    `),B1=R1`
  :root {
    ${I1}
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }

  html, body, #root {
    width: 100%;
    height: 100%;
    overflow: hidden;
  }

  body {
    background: transparent;
    font-family: ${le.font.body};
    color: ${le.color.text};
    -webkit-font-smoothing: antialiased;
    text-rendering: optimizeLegibility;
    user-select: none;
    cursor: default;
  }

  #root { position: relative; }

  .app-stage {
    position: absolute;
    top: 0;
    left: 0;
    width: ${le.layout.stageWidth}px;
    height: ${le.layout.stageHeight}px;
    transform: scale(var(--stage-scale, 1));
    transform-origin: top left;
  }

  /* Thin red scrollbar matching the Figma scroll indicator */
  ::-webkit-scrollbar { width: 4px; }
  ::-webkit-scrollbar-track { background: ${le.color.scrollTrack}; border-radius: 8px; }
  ::-webkit-scrollbar-thumb {
    background: ${le.color.accent};
    border-radius: 8px;
    box-shadow: ${le.shadow.accentGlowSoft};
  }
`,Mp=["noseWidth","nosePeakHigh","nosePeakSize","noseBoneHigh","nosePeakLowering","noseBoneTwist","eyeBrownHigh","eyeBrownForward","cheeksBoneHigh","cheeksBoneWidth","cheeksWidth","eyesOpening","lipsThickness","jawBoneWidth","jawBoneBackSize","chinBoneLowering","chinBoneLenght","chinBoneSize","chinHole","neckThickness"],zp=["blemishes","beard","eyebrows","ageing","makeUp","blush","complexion","sunDamage","lipstick","moleAndFreckles","chestHair","bodyBlemishes"],F1=["beard","eyebrows","chestHair","makeUp","blush","lipstick"],Ap=[0,1,2,3,4,5,6,7,8,9,10,11],Ip=[0,1,2,6,7];function D1(){const e=[];for(let t=0;t<64;t++){const n=t/63;e.push([Math.round(20+n*200),Math.round(15+n*150),Math.round(10+n*120)])}return e}function H1(){const e=[];for(let t=0;t<64;t++){const n=t/63;e.push([Math.round(40+n*180),Math.round(20+n*60),Math.round(30+n*70)])}return e}function br(){const e=D1(),t=H1(),n=(r,o)=>o.map(i=>({...i,zone:r,hashMale:"x",hashFemale:"x"}));return{ped:{model:{items:["mp_m_freemode_01","mp_f_freemode_01"]}},components:Ap.map(r=>({component_id:r,drawable:{min:0,max:40},texture:{min:0,max:8},blacklist:{drawables:[],textures:[]}})),props:Ip.map(r=>({prop_id:r,drawable:{min:-1,max:25},texture:{min:-1,max:5},blacklist:{drawables:[],textures:[]}})),headBlend:{shapeFirst:{min:0,max:45},shapeSecond:{min:0,max:45},shapeThird:{min:0,max:45},skinFirst:{min:0,max:45},skinSecond:{min:0,max:45},skinThird:{min:0,max:45},shapeMix:{min:0,max:1,factor:.1},skinMix:{min:0,max:1,factor:.1},thirdMix:{min:0,max:1,factor:.1}},faceFeatures:Object.fromEntries(Mp.map(r=>[r,{min:-1,max:1,factor:.1}])),headOverlays:Object.fromEntries(zp.map(r=>[r,{style:{min:0,max:25},opacity:{min:0,max:1,factor:.1},...F1.includes(r)?{color:{items:r==="makeUp"||r==="blush"||r==="lipstick"?t:e}}:{}}])),hair:{style:{min:0,max:76},color:{items:e},highlight:{items:e},texture:{min:0,max:4},blacklist:{drawables:[],textures:[]}},eyeColor:{min:0,max:30},tattoos:{items:{ZONE_HEAD:n("ZONE_HEAD",[{label:"Pirate Skull",name:"TAT_BB_021",collection:"mpbeach_overlays"},{label:"Surf LS",name:"TAT_BB_022",collection:"mpbeach_overlays"},{label:"Shark",name:"TAT_BB_031",collection:"mpbeach_overlays"},{label:"Little Fish",name:"TAT_BB_028",collection:"mpbeach_overlays"},{label:"Surfs Up",name:"TAT_BB_029",collection:"mpbeach_overlays"},{label:"Morbid Arachnid",name:"TAT_BI_009",collection:"mpbiker_overlays"}]),ZONE_TORSO:n("ZONE_TORSO",[{label:"Turbulence",name:"TAT_AR_000",collection:"mpairraces_overlays"},{label:"Pilot Skull",name:"TAT_AR_001",collection:"mpairraces_overlays"},{label:"Winged Bombshell",name:"TAT_AR_002",collection:"mpairraces_overlays"},{label:"Balloon Pioneer",name:"TAT_AR_004",collection:"mpairraces_overlays"},{label:"Parachute Belle",name:"TAT_AR_005",collection:"mpairraces_overlays"},{label:"Bombs Away",name:"TAT_AR_006",collection:"mpairraces_overlays"}]),ZONE_LEFT_ARM:n("ZONE_LEFT_ARM",[{label:"Toxic Trails",name:"TAT_AR_003",collection:"mpairraces_overlays"},{label:"Tiki Tower",name:"TAT_BB_024",collection:"mpbeach_overlays"},{label:"Mermaid L.S.",name:"TAT_BB_017",collection:"mpbeach_overlays"},{label:"Urban Stunter",name:"TAT_BI_012",collection:"mpbiker_overlays"},{label:"Macabre Tree",name:"TAT_BI_016",collection:"mpbiker_overlays"},{label:"Cranial Rose",name:"TAT_BI_020",collection:"mpbiker_overlays"}]),ZONE_RIGHT_ARM:n("ZONE_RIGHT_ARM",[{label:"Tribal Sun",name:"TAT_BB_026",collection:"mpbeach_overlays"},{label:"Vespucci Beauty",name:"TAT_BB_030",collection:"mpbeach_overlays"},{label:"Swooping Eagle",name:"TAT_BI_007",collection:"mpbiker_overlays"},{label:"Lady Mortality",name:"TAT_BI_014",collection:"mpbiker_overlays"},{label:"Eagle Emblem",name:"TAT_BI_033",collection:"mpbiker_overlays"},{label:"Grim Rider",name:"TAT_BI_042",collection:"mpbiker_overlays"}]),ZONE_LEFT_LEG:n("ZONE_LEFT_LEG",[{label:"Tribal Star",name:"TAT_BB_027",collection:"mpbeach_overlays"},{label:"Rose Tribute",name:"TAT_BI_002",collection:"mpbiker_overlays"},{label:"Ride or Die",name:"TAT_BI_015",collection:"mpbiker_overlays"},{label:"Bad Luck",name:"TAT_BI_027",collection:"mpbiker_overlays"},{label:"Engulfed Skull",name:"TAT_BI_036",collection:"mpbiker_overlays"},{label:"Scorched Soul",name:"TAT_BI_037",collection:"mpbiker_overlays"}]),ZONE_RIGHT_LEG:n("ZONE_RIGHT_LEG",[{label:"Tribal Tiki Tower",name:"TAT_BB_025",collection:"mpbeach_overlays"},{label:"Dragon's Fury",name:"TAT_BI_004",collection:"mpbiker_overlays"},{label:"Western Insignia",name:"TAT_BI_022",collection:"mpbiker_overlays"},{label:"Dusk Rider",name:"TAT_BI_028",collection:"mpbiker_overlays"},{label:"American Made",name:"TAT_BI_040",collection:"mpbiker_overlays"},{label:"STFU",name:"TAT_BI_048",collection:"mpbiker_overlays"}])},opacity:{min:.1,max:1,factor:.1}}}}function Bl(){return{model:"mp_m_freemode_01",headBlend:{shapeFirst:21,shapeSecond:5,shapeThird:0,skinFirst:21,skinSecond:5,skinThird:0,shapeMix:.5,skinMix:.5,thirdMix:0},faceFeatures:Object.fromEntries(Mp.map(e=>[e,0])),headOverlays:Object.fromEntries(zp.map(e=>[e,{style:0,opacity:0,color:0,secondColor:0}])),components:Ap.map(e=>({component_id:e,drawable:e===11?15:0,texture:0})),props:Ip.map(e=>({prop_id:e,drawable:-1,texture:-1})),hair:{style:4,color:5,highlight:5,texture:0},tattoos:{},eyeColor:0}}const U1={ped:!0,headBlend:!0,faceFeatures:!0,headOverlays:!0,components:!0,componentConfig:{masks:!0,upperBody:!0,lowerBody:!0,bags:!0,shoes:!0,scarfAndChains:!0,bodyArmor:!0,shirts:!0,decals:!0,jackets:!0},props:!0,propConfig:{hats:!0,glasses:!0,ear:!0,watches:!0,bracelets:!0},tattoos:!0,branding:{useLogo:!1,name:"NANO SCRIPTS",logo:"/branding/logo.png",logoWidth:130,logoHeight:0},images:{base:"/shots",format:"webp"},primaryColor:"#ff454b",enableExit:!0,hasTracker:!1,automaticFade:!1,allowChestHairFemale:!1},W1={currentTheme:"nano",themes:[]},V1={app:{title:"Appearance",subtitle:"Customize your character to your liking.",loading:"Loading…",continueButton:"Continue",quit:"Quit",none:"None",rotate:"Rotate",zoom:"Zoom",reset:"Reset",optionsCount:"%s options"},modal:{save:{title:"Save customization",description:"You will remain ugly"},exit:{title:"Exit customization",description:"No changes will be saved"},accept:"Yes",decline:"No"},ped:{title:"Ped",model:"Model"},headBlend:{title:"Inheritance",shape:{title:"Face",firstOption:"Father",secondOption:"Mother",mix:"Mix"},skin:{title:"Skin",firstOption:"Father",secondOption:"Mother",mix:"Mix"},race:{title:"Race",shape:"Shape",skin:"Skin",mix:"Mix"}},faceFeatures:{title:"Face Features",nose:{title:"Nose",width:"Width",height:"Height",size:"Size",boneHeight:"Bone height",boneTwist:"Bone twist",peakHeight:"Peak height"},eyebrows:{title:"Eyebrows",height:"Height",depth:"Depth"},cheeks:{title:"Cheeks",boneHeight:"Bone height",boneWidth:"Bone width",width:"Width"},eyesAndMouth:{title:"Eyes and Mouth",eyesOpening:"Eyes opening",lipsThickness:"Lip thickness"},jaw:{title:"Jaw",width:"Width",size:"Size"},chin:{title:"Chin",lowering:"Lowering",length:"Length",size:"Size",hole:"Hole size"},neck:{title:"Neck",thickness:"Thickness"}},headOverlays:{title:"Appearance",hair:{title:"Hair",style:"Style",color:"Color",highlight:"Highlight",texture:"Texture",fade:"Fade"},opacity:"Opacity",style:"Style",color:"Color",secondColor:"Secondary Color",blemishes:"Blemishes",beard:"Beard",eyebrows:"Eyebrows",ageing:"Ageing",makeUp:"Make up",blush:"Blush",complexion:"Complexion",sunDamage:"Sun damage",lipstick:"Lipstick",moleAndFreckles:"Mole and Freckles",chestHair:"Chest hair",bodyBlemishes:"Body blemishes",eyeColor:"Eye color"},components:{title:"Clothes",drawable:"Drawable",texture:"Texture",mask:"Mask",upperBody:"Hands",lowerBody:"Legs",bags:"Bags and parachute",shoes:"Shoes",scarfAndChains:"Scarf and chains",shirt:"Shirt",bodyArmor:"Body armor",decals:"Decals",jackets:"Jackets",head:"Head",kicker:"Wardrobe",chip:"Apparel"},props:{title:"Props",drawable:"Drawable",texture:"Texture",hats:"Hats and helmets",glasses:"Glasses",ear:"Ear",watches:"Watches",bracelets:"Bracelets",kicker:"Accessory",chip:"Prop"},tattoos:{title:"Tattoos",items:{ZONE_TORSO:"Torso",ZONE_HEAD:"Head",ZONE_LEFT_ARM:"Left arm",ZONE_RIGHT_ARM:"Right arm",ZONE_LEFT_LEG:"Left leg",ZONE_RIGHT_LEG:"Right leg"},apply:"Apply",delete:"Remove",deleteAll:"Remove all Tattoos",opacity:"Opacity",designsCount:"%s designs",appliedCount:"%s on",hint:"Tap a tattoo to apply it, tap again to remove. You're only charged for what's left when you save."}};async function G1(e,t){switch(e){case"appearance_get_locales":return V1;case"appearance_get_settings":return{appearanceSettings:br()};case"appearance_get_data":return{config:U1,appearanceData:Bl()};case"get_theme_configuration":return W1;case"appearance_change_model":{const n=typeof t=="string"?t:Bl().model;return{appearanceSettings:br(),appearanceData:{...Bl(),model:n}}}case"appearance_change_component":{const n=t;return br().components.find(r=>r.component_id===n.component_id)}case"appearance_change_prop":{const n=t;return br().props.find(r=>r.prop_id===n.prop_id)}case"appearance_change_hair":return br().hair;case"appearance_apply_tattoo":return!0;default:return 1}}const pr=()=>typeof window>"u"||!window.GetParentResourceName,eu=()=>window.GetParentResourceName?window.GetParentResourceName():"illenium-appearance";async function xe(e,t){if(pr())return G1(e,t);const n=await fetch(`https://${eu()}/${e}`,{method:"POST",headers:{"Content-Type":"application/json; charset=UTF-8"},body:JSON.stringify(t??{})});try{return await n.json()}catch{return null}}function jc(e,t){const n=j.useRef(t);n.current=t,j.useEffect(()=>{const r=o=>{const i=o.data;i&&typeof i=="object"&&i.type===e&&n.current(i.payload)};return window.addEventListener("message",r),()=>window.removeEventListener("message",r)},[e])}let wo=pr()?"/shots":`https://cfx-nui-${eu()}/shots`,ko="webp";const Bp="png",Fp=pr()?"/categories":`https://cfx-nui-${eu()}/web/dist/categories`;function K1(e,t){e&&(wo=e),t&&(ko=t)}function tu(e){return e&&/_f_/i.test(e)?"female":"male"}function Y1(e,t,n,r){const o=t==="prop"?`prop_${n}`:String(n);return`${wo}/${e}/${o}/${r}.${ko}`}function Q1(e){return`${Fp}/${e}.${Bp}`}function Z1(e,t){return`${wo}/${e}/2/${t}.${ko}`}function X1(e,t,n){return`${wo}/${e}/overlay_${t}/${n}.${ko}`}function J1(e,t){return`${wo}/${e}/tattoos/${t}.${ko}`}const q1={ZONE_HEAD:"tattoo_head",ZONE_TORSO:"tattoo_torso",ZONE_LEFT_ARM:"tattoo_arm",ZONE_RIGHT_ARM:"tattoo_arm",ZONE_LEFT_LEG:"tattoo_leg",ZONE_RIGHT_LEG:"tattoo_leg"};function eg(e){return`${Fp}/${q1[e]??"tattoo_torso"}.${Bp}`}const tg={male:new Set(["blemishes","beard","eyebrows","makeUp","blush","lipstick","chestHair"]),female:new Set(["beard","eyebrows","makeUp","blush","lipstick","chestHair"])};function ng(e,t){return tg[e].has(t)}const rg={male:new Set,female:new Set(["beard","chestHair"])};function og(e,t,n=!1){return e==="female"&&t==="chestHair"&&n?!0:!rg[e].has(t)}const ig=[{id:"ped",titleKey:"ped.title",camera:"default",configKey:"ped"},{id:"headBlend",titleKey:"headBlend.title",camera:"head",configKey:"headBlend"},{id:"faceFeatures",titleKey:"faceFeatures.title",camera:"head",configKey:"faceFeatures"},{id:"headOverlays",titleKey:"headOverlays.title",camera:"head",configKey:"headOverlays"},{id:"components",titleKey:"components.title",camera:"body",configKey:"components"},{id:"props",titleKey:"props.title",camera:"default",configKey:"props"},{id:"tattoos",titleKey:"tattoos.title",camera:"body",configKey:"tattoos"}];function Ga(e){return e?ig.filter(t=>!!e[t.configKey]):[]}const Dp=j.createContext(null);function lg(e){return(t,...n)=>{if(!e)return t;let r=e;for(const i of t.split("."))if(r&&typeof r=="object")r=r[i];else{r=void 0;break}if(typeof r!="string")return t;let o=0;return r.replace(/%s/g,()=>o<n.length?String(n[o++]):"%s")}}function Ho(e){return Promise.race([xe(e).catch(()=>null),new Promise(t=>setTimeout(()=>t(null),8e3))])}function ag({children:e}){const[t,n]=j.useState(!1),[r,o]=j.useState(!1),[i,l]=j.useState(null),[a,s]=j.useState(null),[c,m]=j.useState(null),[h,f]=j.useState(null),[w,v]=j.useState(null),[k,_]=j.useState(!1),p=j.useRef(0),d=j.useCallback(async W=>{const[z,Ae]=await Promise.all([Ho("appearance_get_locales"),Ho("get_theme_configuration")]),ht=P=>!!(P?.appearanceData&&Ga(P.config??null).length>0);let _e=null,ce=null;for(let P=0;P<4&&W===p.current&&(P>0&&await new Promise(N=>setTimeout(N,500)),[_e,ce]=await Promise.all([_e?.appearanceSettings?_e:Ho("appearance_get_settings"),ht(ce)?ce:Ho("appearance_get_data")]),!(_e?.appearanceSettings&&ht(ce)));P++);if(W!==p.current)return!1;v(z),f(Ae),s(_e?.appearanceSettings??null),K1(ce?.config?.images?.base,ce?.config?.images?.format);const T=ce?.config?.primaryColor?.trim();return T&&/^#?[0-9a-fA-F]{6}$/.test(T)&&qs(T.startsWith("#")?T:`#${T}`),l(ce?.config??null),m(ce?.appearanceData??null),_(!_e?.appearanceSettings||!ce?.appearanceData||Ga(ce?.config??null).length===0),o(!0),!0},[]);jc("appearance_display",async W=>{const z=++p.current;o(!1),_(!1),W?.asynchronous?(n(!0),d(z)):await d(z)&&n(!0)}),jc("appearance_hide",()=>{p.current++,n(!1),o(!1)});const g=j.useCallback(W=>{m(z=>z&&W(z))},[]),S=j.useCallback(W=>{s(z=>z&&W(z))},[]),y=j.useCallback(async()=>{if(!c){n(!1);return}(await xe("appearance_save",c))?.ok!==!1&&n(!1)},[c]),C=j.useCallback(()=>{xe("appearance_exit"),n(!1)},[]),b=j.useCallback(W=>{xe("appearance_set_camera",W)},[]),$=j.useCallback((W,z)=>{xe("appearance_orbit_camera",{dx:W,dy:z})},[]),R=j.useCallback(W=>{xe("appearance_zoom_camera",W)},[]),O=j.useCallback(()=>{xe("appearance_turn_around")},[]),D=j.useMemo(()=>({visible:t,ready:r,failed:k,config:i,settings:a,data:c,theme:h,t:lg(w),setData:g,setSettings:S,save:y,exit:C,setCamera:b,orbitCamera:$,zoomCamera:R,turnAround:O}),[t,r,k,i,a,c,h,w,g,S,y,C,b,$,R,O]);return u.jsx(Dp.Provider,{value:D,children:e})}function Ge(){const e=j.useContext(Dp);if(!e)throw new Error("useApp must be used within AppProvider");return e}function Ri({size:e=14,style:t,className:n}){return u.jsx("svg",{width:e,height:e*2,viewBox:"0 0 13.7944 27.5888",fill:"none",style:t,className:n,children:u.jsx("path",{fillRule:"evenodd",clipRule:"evenodd",d:"M11.6755 14.6118L5.17255 21.1147L3.54711 19.4893L9.2373 13.7991L3.54711 8.10889L5.17255 6.48345L11.6755 12.9864C11.891 13.2019 12.012 13.4943 12.012 13.7991C12.012 14.1039 11.891 14.3962 11.6755 14.6118Z",fill:"currentColor"})})}function sg({size:e=18,style:t,className:n}){return u.jsx("svg",{width:e,height:e,viewBox:"0 0 18 18",fill:"none",style:t,className:n,children:u.jsx("path",{fillRule:"evenodd",clipRule:"evenodd",d:"M8.01643 1.92857C5.67257 1.92857 3.53571 4.12714 3.53571 6.498C3.53571 6.75374 3.43412 6.99901 3.25328 7.17985C3.07244 7.36069 2.82717 7.46229 2.57143 7.46229C2.31568 7.46229 2.07041 7.36069 1.88958 7.17985C1.70874 6.99901 1.60714 6.75374 1.60714 6.498C1.60586 3.10371 4.56557 0 8.01643 0C8.27217 0 8.51744 0.101594 8.69828 0.282433C8.87912 0.463271 8.98071 0.708541 8.98071 0.964286C8.98071 1.22003 8.87912 1.4653 8.69828 1.64614C8.51744 1.82698 8.27217 1.92857 8.01643 1.92857ZM7.41214 11.0983V11.2989C7.41214 12.1474 7.45843 12.9896 7.52143 13.8266C7.61786 15.0994 8.65286 16.2051 9.96943 16.3337C10.3474 16.3714 10.7246 16.3911 11.1009 16.3929C11.664 16.3954 11.8504 16.3697 12.231 16.3324C13.5463 16.2039 14.5813 15.0981 14.6777 13.8253C14.7407 12.9896 14.787 12.1474 14.787 11.2989C14.787 10.4503 14.7407 9.60686 14.6777 8.76986C14.5813 7.49829 13.5463 6.39257 12.231 6.26271C11.9996 6.24014 11.7677 6.22385 11.5354 6.21386C11.6434 7.11771 11.6717 8.01 11.6177 8.91C11.5457 10.1289 10.5891 11.124 9.35229 11.178C8.70491 11.2058 8.05506 11.1791 7.41214 11.0983ZM11.1009 4.59643C10.671 4.59761 10.2414 4.62036 9.81386 4.66457C7.70014 4.87029 6.07243 6.61886 5.92071 8.65029C5.84886 9.53136 5.81069 10.4149 5.80629 11.2989C5.80629 12.2053 5.85643 13.0911 5.92071 13.9474C6.07371 15.9763 7.70014 17.7249 9.81386 17.9331C10.2317 17.973 10.6624 18 11.1009 18C11.5406 17.9983 11.9696 17.9756 12.3879 17.9319C14.5016 17.7261 16.1293 15.9776 16.281 13.9461C16.3453 13.0911 16.3954 12.2053 16.3954 11.2976C16.3954 10.3924 16.3453 9.50529 16.281 8.649C16.1293 6.62014 14.5016 4.87157 12.3879 4.66329C11.97 4.62343 11.5393 4.59643 11.1021 4.59643",fill:"currentColor"})})}function ug({size:e=18,style:t,className:n}){return u.jsx("svg",{width:e,height:e,viewBox:"0 0 18 18",fill:"none",style:t,className:n,children:u.jsxs("g",{transform:"translate(3 1)",children:[u.jsx("path",{d:"M4.90316 15.375C3.13091 14.7124 1.65303 12.4444 0.913156 11.1161C0.593656 10.5424 0.762031 9.83813 1.27466 9.42788C1.55066 9.20718 1.89834 9.09599 2.25118 9.11557C2.60402 9.13515 2.93727 9.28412 3.18716 9.534L3.77816 10.125V6.9375C3.77816 6.68886 3.87693 6.4504 4.05274 6.27459C4.22856 6.09877 4.46702 6 4.71566 6C4.9643 6 5.20275 6.09877 5.37857 6.27459C5.55438 6.4504 5.65316 6.68886 5.65316 6.9375V5.4375C5.65316 5.18886 5.75193 4.9504 5.92774 4.77459C6.10356 4.59877 6.34202 4.5 6.59066 4.5C6.8393 4.5 7.07775 4.59877 7.25357 4.77459C7.42938 4.9504 7.52816 5.18886 7.52816 5.4375V8.4375C7.52816 8.18886 7.62693 7.9504 7.80274 7.77459C7.97856 7.59877 8.21702 7.5 8.46566 7.5C8.7143 7.5 8.95275 7.59877 9.12857 7.77459C9.30438 7.9504 9.40316 8.18886 9.40316 8.4375V9.5625C9.40316 9.31386 9.50193 9.0754 9.67774 8.89959C9.85356 8.72377 10.092 8.625 10.3407 8.625C10.5893 8.625 10.8278 8.72377 11.0036 8.89959C11.1794 9.0754 11.2782 9.31386 11.2782 9.5625V12.513C11.2782 12.9143 11.1788 13.311 10.9474 13.6391C10.5638 14.1825 9.87416 15.0127 9.02816 15.375C7.71566 15.9375 6.54191 15.9877 4.90316 15.375Z",fill:"currentColor",stroke:"currentColor",strokeWidth:"1.5",strokeLinecap:"round",strokeLinejoin:"round"}),u.jsx("path",{d:"M2.27816 2.25H10.5282M3.77816 0.75L2.27816 2.25L3.77816 3.75M9.02816 3.75L10.5282 2.25L9.02816 0.75",stroke:"currentColor",strokeWidth:"1.5",strokeLinecap:"round",strokeLinejoin:"round"})]})})}function cg({size:e=16,style:t,className:n}){return u.jsx("svg",{width:e,height:e,viewBox:"0 0 16 16",fill:"none",style:t,className:n,children:u.jsx("path",{d:"M7.333 12.667A5.333 5.333 0 1 0 7.333 2a5.333 5.333 0 0 0 0 10.667ZM14 14l-2.9-2.9",stroke:"currentColor",strokeWidth:"1.5",strokeLinecap:"round",strokeLinejoin:"round"})})}function dg({size:e=18,style:t,className:n}){return u.jsxs("svg",{width:e,height:e,viewBox:"0 0 14.625 14.625",fill:"none",style:t,className:n,children:[u.jsx("path",{d:"M5.625 7.3125V4.6875C5.625 4.58804 5.66451 4.49266 5.73483 4.42233C5.80516 4.35201 5.90054 4.3125 6 4.3125H8.25C8.54837 4.3125 8.83452 4.43103 9.0455 4.642C9.25647 4.85298 9.375 5.13913 9.375 5.4375V6.1875C9.375 6.48587 9.25647 6.77202 9.0455 6.983C8.83452 7.19397 8.54837 7.3125 8.25 7.3125H6.9375M5.625 7.3125V10.3125M5.625 7.3125H6.9375M6.9375 7.3125L9.1875 10.3125",stroke:"currentColor",strokeWidth:"1.125",strokeLinecap:"round",strokeLinejoin:"round"}),u.jsx("path",{d:"M0.5625 5.3625C0.5625 3.6825 0.5625 2.8425 0.8895 2.2005C1.17712 1.63604 1.63604 1.17712 2.2005 0.8895C2.8425 0.5625 3.6825 0.5625 5.3625 0.5625H9.2625C10.9425 0.5625 11.7825 0.5625 12.4245 0.8895C12.989 1.17712 13.4479 1.63604 13.7355 2.2005C14.0625 2.8425 14.0625 3.6825 14.0625 5.3625V9.2625C14.0625 10.9425 14.0625 11.7825 13.7355 12.4245C13.4479 12.989 12.989 13.4479 12.4245 13.7355C11.7825 14.0625 10.9425 14.0625 9.2625 14.0625H5.3625C3.6825 14.0625 2.8425 14.0625 2.2005 13.7355C1.63604 13.4479 1.17712 12.989 0.8895 12.4245C0.5625 11.7825 0.5625 10.9425 0.5625 9.2625V5.3625Z",stroke:"currentColor",strokeWidth:"1.125",strokeLinecap:"round",strokeLinejoin:"round"})]})}function bn({size:e=18,style:t,className:n,children:r}){return u.jsx("svg",{width:e,height:e,viewBox:"0 0 24 24",fill:"none",style:t,className:n,children:u.jsx("g",{stroke:"currentColor",strokeWidth:1.7,strokeLinecap:"round",strokeLinejoin:"round",children:r})})}function fg(e){return u.jsxs(bn,{...e,children:[u.jsx("circle",{cx:"12",cy:"7.5",r:"3.3"}),u.jsx("path",{d:"M5.5 19.5c0-3.6 2.9-6.2 6.5-6.2s6.5 2.6 6.5 6.2"})]})}function pg(e){return u.jsxs(bn,{...e,children:[u.jsx("circle",{cx:"9",cy:"8.5",r:"3.1"}),u.jsx("path",{d:"M3.8 19c0-3.2 2.3-5.4 5.2-5.4s5.2 2.2 5.2 5.4"}),u.jsx("path",{d:"M16 5.7a3.1 3.1 0 0 1 0 5.7"}),u.jsx("path",{d:"M16.4 14c2.4.5 4 2.6 4 5"})]})}function hg(e){return u.jsxs(bn,{...e,children:[u.jsx("path",{d:"M12 21c4.4 0 7-3.6 7-9s-2.6-9-7-9-7 3.6-7 9 2.6 9 7 9Z"}),u.jsx("path",{d:"M9.2 11h.01"}),u.jsx("path",{d:"M14.8 11h.01"}),u.jsx("path",{d:"M12 12.2v1.7"}),u.jsx("path",{d:"M9.8 16.2c1.3 1 3.1 1 4.4 0"})]})}function mg(e){return u.jsxs(bn,{...e,children:[u.jsx("path",{d:"M12 3.5l1.5 4.2 4.2 1.5-4.2 1.5L12 14.9l-1.5-4.2L6.3 9.2l4.2-1.5L12 3.5Z"}),u.jsx("path",{d:"M18 14l.8 2 2 .8-2 .8-.8 2-.8-2-2-.8 2-.8.8-2Z"})]})}function gg(e){return u.jsx(bn,{...e,children:u.jsx("path",{d:"M8.5 4 4 6.6l2 3.2 2.1-1.1V20h7.8V8.7l2.1 1.1 2-3.2L15.5 4c0 1.6-1.6 2.9-3.5 2.9S8.5 5.6 8.5 4Z"})})}function yg(e){return u.jsxs(bn,{...e,children:[u.jsx("circle",{cx:"7",cy:"13",r:"3.3"}),u.jsx("circle",{cx:"17",cy:"13",r:"3.3"}),u.jsx("path",{d:"M10.3 12.6c.9-.5 2.5-.5 3.4 0"}),u.jsx("path",{d:"M3.7 13c0-2.4 1-3.8 2.6-4.4"}),u.jsx("path",{d:"M20.3 13c0-2.4-1-3.8-2.6-4.4"})]})}function xg(e){return u.jsxs(bn,{...e,children:[u.jsx("path",{d:"M17 3a2.83 2.83 0 0 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3Z"}),u.jsx("path",{d:"M15 5l4 4"})]})}const vg=""+new URL("sep.CaMymGIG.svg",import.meta.url).href,{color:U,font:nu,radius:st,shadow:Mi}=le,qt=x.div`
  font-family: ${nu.body};
  font-size: 14px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  color: ${U.textLabel};
  margin-bottom: 12px;
`,mn=x.div`
  margin-bottom: 26px;
`,Tc=x.img.attrs({src:vg,alt:"","aria-hidden":!0})`
  display: block;
  width: 100%;
  height: auto;
  margin: 4px 0 22px;
`,rt=x.div`
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 14px;
`,$e=x.div`
  flex: 0 0 120px;
  font-size: 13px;
  color: ${U.textMuted};
`;function wg({value:e,onChange:t,placeholder:n="Search"}){return u.jsxs(kg,{children:[u.jsx(cg,{size:15}),u.jsx(Sg,{type:"text",value:e,placeholder:n,spellCheck:!1,onChange:r=>t(r.target.value)}),e!==""&&u.jsx($g,{type:"button","aria-label":"Clear search",onClick:()=>t(""),children:"×"})]})}const kg=x.div`
  display: flex;
  align-items: center;
  gap: 10px;
  height: 42px;
  padding: 0 12px;
  margin-bottom: 12px;
  border-radius: ${st.md};
  border: 1px solid ${U.border};
  background: ${U.surface05};
  color: ${U.textMuted};
  transition: border-color 0.12s ease, color 0.12s ease;
  &:focus-within {
    border-color: ${U.accent};
    color: ${U.text};
  }
`,Sg=x.input`
  flex: 1;
  min-width: 0;
  border: none;
  outline: none;
  background: transparent;
  font-family: ${nu.body};
  font-size: 14px;
  color: ${U.text};
  &::placeholder { color: ${U.textDim}; }
`,$g=x.button`
  flex: 0 0 auto;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  cursor: pointer;
  border-radius: ${st.pill};
  background: ${U.surface15};
  color: ${U.textMuted};
  font-size: 15px;
  line-height: 1;
  transition: background 0.12s ease, color 0.12s ease;
  &:hover { background: ${U.accent}; color: #fff; }
`;function bg({label:e,onPrev:t,onNext:n,disabledPrev:r,disabledNext:o}){return u.jsxs(Cg,{children:[u.jsx(Lc,{$side:"left",disabled:r,onClick:t,children:u.jsx(Ri,{size:12,style:{transform:"scaleX(-1)"}})}),u.jsx(_g,{children:e}),u.jsx(Lc,{$side:"right",disabled:o,onClick:n,children:u.jsx(Ri,{size:12})})]})}function yt({value:e,min:t,max:n,onChange:r,format:o,wrap:i=!0}){const l=j.useCallback(v=>{let k=e+v;k>n&&(k=i?t:n),k<t&&(k=i?n:t),r(k)},[e,t,n,i,r]),[a,s]=j.useState(!1),[c,m]=j.useState(""),h=j.useCallback(()=>{const v=Number(c);c.trim()!==""&&Number.isFinite(v)&&r(Math.min(n,Math.max(t,Math.round(v)))),s(!1)},[c,t,n,r]),f=n<=t,w=o?o(e):String(e);return u.jsx(bg,{onPrev:()=>l(-1),onNext:()=>l(1),disabledPrev:f,disabledNext:f,label:a?u.jsx(jg,{type:"text",inputMode:"numeric",autoFocus:!0,value:c,onChange:v=>m(v.target.value),onFocus:v=>v.currentTarget.select(),onBlur:h,onKeyDown:v=>{v.key==="Enter"?h():v.key==="Escape"&&s(!1)}}):u.jsx(Eg,{title:"Click to type a value",onClick:()=>{m(String(e)),s(!0)},children:w})})}const Cg=x.div`
  display: flex;
  align-items: stretch;
  height: 42px;
  width: 100%;
`,Lc=x.button`
  flex: 0 0 42px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  cursor: pointer;
  color: ${U.text};
  background: ${U.surface15};
  border-radius: ${e=>e.$side==="left"?`${st.lg} 0 0 ${st.lg}`:`0 ${st.lg} ${st.lg} 0`};
  transition: background 0.12s ease, box-shadow 0.12s ease;

  &:hover:not(:disabled) {
    background: ${U.accent};
    box-shadow: ${Mi.accentGlow};
  }
  &:active:not(:disabled) { filter: brightness(0.95); }
  &:disabled { opacity: 0.4; cursor: default; }
`,_g=x.div`
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 6px;
  background: ${U.surface05};
  border-radius: ${st.sm};
  font-size: 14px;
  color: ${U.textMuted};
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  padding: 0 8px;
`,Eg=x.span`
  display: block;
  width: 100%;
  cursor: text;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
`,jg=x.input`
  width: 100%;
  min-width: 0;
  border: none;
  outline: none;
  background: transparent;
  text-align: center;
  font-family: ${nu.body};
  font-size: 14px;
  color: ${U.text};
  &::-webkit-outer-spin-button,
  &::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
`;function Wr({value:e,min:t,max:n,step:r=1,onChange:o,showValue:i=!0,format:l,center:a=!1}){const s=j.useRef(null),c=n>t?(e-t)/(n-t):0,m=Math.min(c,.5),h=Math.max(c,.5),f=j.useCallback(_=>{const p=s.current;if(!p)return;const d=p.getBoundingClientRect(),g=Math.min(1,Math.max(0,(_-d.left)/d.width));let S=t+g*(n-t);r>0&&(S=Math.round(S/r)*r),o(Math.min(n,Math.max(t,S)))},[t,n,r,o]),w=j.useCallback(_=>{_.preventDefault(),_.currentTarget.setPointerCapture(_.pointerId),f(_.clientX)},[f]),v=j.useCallback(_=>{_.buttons===1&&f(_.clientX)},[f]),k=j.useCallback(_=>{const p=r>0?r:(n-t)/100;_.key==="ArrowLeft"||_.key==="ArrowDown"?(o(Math.max(t,e-p)),_.preventDefault()):(_.key==="ArrowRight"||_.key==="ArrowUp")&&(o(Math.min(n,e+p)),_.preventDefault())},[e,t,n,r,o]);return u.jsxs(Lg,{children:[u.jsxs(Pg,{ref:s,$center:a,style:{"--frac":c,"--c-left":m,"--c-width":h-m},role:"slider",tabIndex:0,"aria-valuemin":t,"aria-valuemax":n,"aria-valuenow":e,onPointerDown:w,onPointerMove:v,onKeyDown:k,children:[u.jsx(Ng,{$center:a}),u.jsx(Og,{$center:a})]}),i&&u.jsx(Rg,{children:l?l(e):Tg(e,r)})]})}function Tg(e,t){return t>=1?String(Math.round(e)):e.toFixed(t.toString().split(".")[1]?.length??1)}const Lg=x.div`
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
`,Pg=x.div`
  --frac: 0;
  --c-left: 0;
  --c-width: 0;
  position: relative;
  flex: 1;
  height: 7px;
  border-radius: ${st.pill};
  background: ${U.surface15};
  cursor: pointer;
  touch-action: none;
  outline: none;
  &:focus-visible { box-shadow: 0 0 0 2px ${U.accentSoft}; }
  ${e=>e.$center&&`&::before {
      content: "";
      position: absolute;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
      width: 2px;
      height: 13px;
      border-radius: 1px;
      background: rgba(255, 255, 255, 0.45);
      pointer-events: none;
    }`}
`,Ng=x.div`
  position: absolute;
  top: 0;
  bottom: 0;
  border-radius: ${st.pill};
  background: ${U.accent};
  pointer-events: none;
  ${e=>e.$center?"left: calc(var(--c-left) * 100%); width: calc(var(--c-width) * 100%);":"left: 0; width: calc(var(--frac) * 100%); filter: brightness(calc(0.55 + var(--frac) * 0.7)) saturate(calc(0.7 + var(--frac) * 0.6));"}
`,Og=x.div`
  position: absolute;
  top: 50%;
  left: calc(var(--frac) * 100%);
  transform: translate(-50%, -50%);
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: ${U.accent};
  pointer-events: none;
  box-shadow: ${e=>e.$center?`0 0 14px 1px ${U.accentGlow}`:`0 0 calc(4px + var(--frac) * 22px) calc(var(--frac) * 4px) ${U.accentGlow}`};
`,Rg=x.div`
  flex: 0 0 38px;
  text-align: right;
  font-size: 12px;
  color: ${U.textMuted};
  font-variant-numeric: tabular-nums;
`,Ka=e=>Math.min(1,Math.max(0,e));function Pc(e,t){const n=t.min+e*(t.max-t.min),r=t.step??0,o=r>0?Math.round(n/r)*r:n;return Math.min(t.max,Math.max(t.min,o))}function Nc(e){return e.max>e.min?(e.value-e.min)/(e.max-e.min):.5}function Mg({x:e,y:t,onChange:n,size:r=176,line:o}){const i=j.useRef(null),[l,a]=j.useState(!1),s=j.useCallback((v,k)=>{const _=i.current;if(!_)return;const p=_.getBoundingClientRect(),d={};e&&(d.x=Pc(Ka((v-p.left)/p.width),e)),t&&(d.y=Pc(Ka(1-(k-p.top)/p.height),t)),(d.x!==void 0||d.y!==void 0)&&n(d)},[e,t,n]),c=j.useCallback(v=>{v.preventDefault(),v.currentTarget.setPointerCapture(v.pointerId),a(!0),s(v.clientX,v.clientY)},[s]),m=j.useCallback(v=>{v.buttons===1&&s(v.clientX,v.clientY)},[s]),h=j.useCallback(()=>a(!1),[]),f=e?Nc(e):.5,w=t?Nc(t):.5;return o?u.jsx(Oc,{children:u.jsxs(Rc,{children:[e&&u.jsx(Pn,{$pos:"left",style:Ln(1-f),children:e.minLabel}),u.jsxs(Ag,{ref:i,style:{width:r},onPointerDown:c,onPointerMove:m,onPointerUp:h,onPointerCancel:h,children:[u.jsx(Ig,{}),u.jsx(Bg,{}),u.jsx(Mc,{$active:l,style:{left:`${f*100}%`,top:"50%"}})]}),e&&u.jsx(Pn,{$pos:"right",style:Ln(f),children:e.maxLabel})]})}):u.jsxs(Oc,{children:[t&&u.jsx(Pn,{$pos:"top",style:Ln(w),children:t.maxLabel}),u.jsxs(Rc,{children:[e&&u.jsx(Pn,{$pos:"left",style:Ln(1-f),children:e.minLabel}),u.jsx(zg,{ref:i,style:{width:r,height:r},onPointerDown:c,onPointerMove:m,onPointerUp:h,onPointerCancel:h,children:u.jsx(Mc,{$active:l,style:{left:`${f*100}%`,top:`${(1-w)*100}%`}})}),e&&u.jsx(Pn,{$pos:"right",style:Ln(f),children:e.maxLabel})]}),t&&u.jsx(Pn,{$pos:"bottom",style:Ln(1-w),children:t.minLabel})]})}function Ln(e){return{"--i":Ka(e).toFixed(3)}}const Oc=x.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  user-select: none;
`,Rc=x.div`
  display: flex;
  align-items: center;
  /* The label + pad + label row is rigid (~324px). When the panel is narrower
     than that, the row gets clamped and the default flex-start would pack its
     children left, shoving the pad off-centre. Centre the overflow instead. */
  justify-content: center;
  gap: 10px;
`,zg=x.div`
  position: relative;
  flex: 0 0 auto;
  border: 1px solid ${U.borderSoft};
  border-radius: ${st.md};
  cursor: crosshair;
  touch-action: none;
  background:
    conic-gradient(
      from 0deg at 50% 50%,
      rgba(255, 255, 255, 0.03) 0 25%,
      transparent 0 50%,
      rgba(255, 255, 255, 0.03) 0 75%,
      transparent 0 100%
    ),
    linear-gradient(to right, transparent calc(50% - 0.75px), rgba(255, 255, 255, 0.22) 50%, transparent calc(50% + 0.75px)),
    linear-gradient(to bottom, transparent calc(50% - 0.75px), rgba(255, 255, 255, 0.22) 50%, transparent calc(50% + 0.75px)),
    rgba(0, 0, 0, 0.5);
  box-shadow: inset 0 0 30px rgba(0, 0, 0, 0.5);
`,Ag=x.div`
  position: relative;
  flex: 0 0 auto;
  height: 24px;
  display: flex;
  align-items: center;
  cursor: pointer;
  touch-action: none;
`,Ig=x.div`
  position: absolute;
  left: 0;
  right: 0;
  top: 50%;
  height: 2px;
  transform: translateY(-50%);
  border-radius: ${st.pill};
  background: ${U.surface15};
  pointer-events: none;
`,Bg=x.div`
  position: absolute;
  left: 50%;
  top: 50%;
  width: 2px;
  height: 10px;
  transform: translate(-50%, -50%);
  background: ${U.borderSoft};
  pointer-events: none;
`,Mc=x.div`
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 3px;
  background: ${U.accent};
  border: 1.5px solid #fff;
  box-shadow: ${e=>e.$active?Mi.accentGlow:Mi.accentGlowSoft};
  transform: translate(-50%, -50%) scale(${e=>e.$active?1.18:1});
  pointer-events: none;
  transition: box-shadow 0.16s ease, transform 0.12s ease;
`,Pn=x.div`
  --i: 0.5;
  font-size: 12px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  white-space: nowrap;
  opacity: calc(0.42 + var(--i) * 0.58);
  color: rgb(
    calc(207 + (var(--accent-r) - 207) * var(--i) * 0.9),
    calc(207 + (var(--accent-g) - 207) * var(--i) * 0.9),
    calc(207 + (var(--accent-b) - 207) * var(--i) * 0.9)
  );
  text-shadow: 0 0 calc(var(--i) * 13px) rgba(var(--accent-rgb), 0.44);
  transition: color 0.1s linear, opacity 0.1s linear, text-shadow 0.1s linear;
  ${e=>e.$pos==="left"||e.$pos==="right"?"flex: 0 0 64px;":""}
  text-align: ${e=>e.$pos==="left"?"right":e.$pos==="right"?"left":"center"};
`;function Fl({items:e,value:t,onChange:n}){return u.jsx(Fg,{children:e.map((r,o)=>u.jsx(Dg,{$active:o===t,style:{background:`rgb(${r[0]}, ${r[1]}, ${r[2]})`},onClick:()=>n(o)},o))})}const Fg=x.div`
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
`,Dg=x.button`
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  border: 2px solid ${e=>e.$active?U.accent:"transparent"};
  outline: 1px solid rgba(0, 0, 0, 0.35);
  outline-offset: -1px;
  box-shadow: ${e=>e.$active?Mi.accentGlowSoft:"none"};
  transition: transform 0.12s ease, border-color 0.12s ease;
  &:hover { transform: scale(1.08); }
`,{color:I,font:So,radius:tt,shadow:Hp}=le,Hg=e=>{e.currentTarget.style.display="none"};x.div`
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
`;x.button`
  height: 32px;
  padding: 0 14px;
  border-radius: ${tt.pill};
  cursor: pointer;
  font-family: ${So.body};
  font-size: 12px;
  letter-spacing: 0.3px;
  white-space: nowrap;
  color: ${e=>e.$active?"#fff":I.textMuted};
  border: 1px solid ${e=>e.$active?I.accent:"rgba(255, 255, 255, 0.12)"};
  background: ${e=>e.$active?"rgba(var(--accent-rgb), 0.18)":I.surface05};
  box-shadow: ${e=>e.$active?"0 0 14px rgba(var(--accent-rgb), 0.45)":"none"};
  transition: all 0.12s ease;
  &:hover { color: #fff; border-color: ${e=>e.$active?I.accent:"rgba(255,255,255,0.28)"}; }
`;x.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));
  gap: 8px;
`;x.button`
  aspect-ratio: 1 / 1;
  border-radius: ${tt.sm};
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding: 8px;
  border: 1px solid ${e=>e.$active?I.accent:"rgba(255, 255, 255, 0.12)"};
  background: linear-gradient(180deg, ${I.surface20}, ${I.surfaceGreyFaint});
  box-shadow: ${e=>e.$active?"0 0 16px rgba(var(--accent-rgb), 0.55)":"none"};
  transition: all 0.12s ease;
  &:hover { transform: translateY(-2px); border-color: ${e=>e.$active?I.accent:"rgba(255,255,255,0.28)"}; }
`;x.img`
  width: 100%;
  height: 100%;
  object-fit: contain;
`;x.div`
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${e=>e.$active?"#fff":I.textMuted};
`;x.div`
  font-family: ${So.body};
  font-size: 10px;
  line-height: 1.1;
  text-align: center;
  color: ${e=>e.$active?"#fff":I.textMuted};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
`;x.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
`;x.div`
  position: relative;
  height: 86px;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 16px 0 14px;
  border-radius: ${tt.md};
  background: ${e=>e.$active?`linear-gradient(90deg, ${I.accentFaint}, ${I.accentSoft})`:`linear-gradient(90deg, ${I.surface03}, ${I.surfaceGrey})`};
  transition: all 0.12s ease;
  cursor: pointer;

  &:hover { filter: brightness(1.12); }

  /* Custom border: a 1px ring drawn on ::after, coloured at the left (accent red
     when active, grey otherwise) and fading to transparent toward the right. The
     two masks cut out the interior so only the ring shows. */
  &::after {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: inherit;
    padding: 1px;
    background: ${e=>e.$active?`linear-gradient(90deg, ${I.accent} 0%, rgba(var(--accent-rgb), 0) 100%)`:"linear-gradient(90deg, rgba(217, 217, 217, 0.65) 0%, rgba(217, 217, 217, 0) 100%)"};
    -webkit-mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    -webkit-mask-composite: xor;
    mask-composite: exclude;
    pointer-events: none;
  }
`;x.div`
  flex: 0 0 60px;
  height: 60px;
  border-radius: ${tt.md};
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${e=>e.$active?"#fff":I.textMuted};
  background: radial-gradient(
    circle at 50% 40%,
    ${e=>e.$active?"rgba(var(--accent-rgb),0.4)":"rgba(217,217,217,0.4)"} 0%,
    rgba(115, 115, 115, 0) 100%
  );
  overflow: hidden;
`;x.img`
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: ${tt.md};
`;x.div`
  flex: 1;
  min-width: 0;
`;x.div`
  font-family: ${So.body};
  font-weight: 700;
  font-size: 16px;
  color: ${I.text};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;x.div`
  margin-top: 4px;
  font-size: 12px;
  color: ${I.textFaint};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;x.button`
  flex: 0 0 auto;
  min-width: 82px;
  height: 28px;
  border-radius: ${tt.sm};
  border: none;
  cursor: pointer;
  font-family: ${So.body};
  font-size: 12px;
  letter-spacing: 1px;
  color: ${e=>e.$active?"#fff":I.textDim};
  background: ${e=>e.$active?I.accent:I.surface20};
  transition: all 0.12s ease;
  &:hover { color: #fff; background: ${e=>e.$active?I.accent:"rgba(var(--accent-rgb),0.5)"}; }
`;const Ug=x.div`
  padding: 28px 16px;
  text-align: center;
  font-size: 13px;
  color: ${I.textFaint};
  border: 1px dashed ${I.border};
  border-radius: ${tt.md};
`;function Wg({items:e,onSelect:t,emptyLabel:n}){return!e.length&&n?u.jsx(Ug,{children:n}):u.jsx(Vg,{children:e.map(r=>u.jsxs(Gg,{$active:!!r.active,title:r.name,onClick:()=>t(r.id),children:[u.jsx(Kg,{children:r.image?u.jsx(Yg,{src:r.image,alt:"",loading:"lazy",onError:o=>{o.currentTarget.style.display="none"}}):r.icon}),u.jsx(Qg,{}),u.jsx(Zg,{children:r.name})]},r.id))})}const Vg=x.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
`,Gg=x.button`
  position: relative;
  display: block;
  width: 100%;
  padding: 0;
  cursor: pointer;
  border-radius: ${tt.md};
  overflow: hidden;
  border: 1px solid ${e=>e.$active?I.accent:I.border};
  background: ${I.surface05};
  box-shadow: ${e=>e.$active?Hp.accentGlow:"none"};
  transition: border-color 0.14s ease, box-shadow 0.14s ease, transform 0.14s ease;
  &:hover { transform: translateY(-2px); border-color: ${e=>e.$active?I.accent:"rgba(255,255,255,0.3)"}; }
`,Kg=x.div`
  position: relative;
  aspect-ratio: 4 / 5;
  overflow: hidden;
  padding: 14px 16px 0;
  background: radial-gradient(120% 90% at 50% 0%, rgba(255, 255, 255, 0.1), rgba(0, 0, 0, 0.4) 78%);
`,Yg=x.img`
  width: 100%;
  height: auto;
  display: block;
`,Qg=x.div`
  position: absolute;
  inset: 0;
  background: linear-gradient(0deg, rgba(0, 0, 0, 0.85) 0%, transparent 42%);
  pointer-events: none;
`,Zg=x.div`
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 8px 8px 9px;
  font-size: 11px;
  text-align: center;
  color: ${I.text};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  letter-spacing: 0.3px;
`;x.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
`;x.button`
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 0;
  border: none;
  background: none;
  cursor: pointer;
`;x.div`
  position: relative;
  aspect-ratio: 1 / 1;
  border-radius: ${tt.sm};
  background: linear-gradient(180deg, rgba(217, 217, 217, 0.2) 0%, rgba(115, 115, 115, 0.1) 100%);
  border: 1px solid ${e=>e.$active?I.accent:"rgba(255, 255, 255, 0.16)"};
  box-shadow: ${e=>e.$active?Hp.accentGlow:"none"};
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color 0.14s ease, box-shadow 0.14s ease, transform 0.14s ease;
  &:hover { transform: translateY(-2px); border-color: ${e=>e.$active?I.accent:"rgba(255,255,255,0.32)"}; }
`;x.span`
  position: absolute;
  font-size: 22px;
  font-variant-numeric: tabular-nums;
  color: rgba(255, 255, 255, 0.18);
`;x.img`
  position: relative;
  z-index: 1;
  width: 86%;
  height: 86%;
  object-fit: contain;
`;x.div`
  position: absolute;
  z-index: 2;
  right: 6px;
  bottom: 6px;
  padding: 2px 8px;
  border-radius: ${tt.pill};
  background: rgba(0, 0, 0, 0.6);
  border: 1px solid ${I.border};
  font-size: 11px;
  color: #fff;
  font-variant-numeric: tabular-nums;
`;x.div`
  font-size: 12px;
  text-align: center;
  color: ${e=>e.$active?I.text:I.textMuted};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`;const Up=x.div`
  position: absolute;
  top: 7px;
  left: 7px;
  z-index: 2;
  padding: 2px 8px;
  border-radius: ${tt.pill};
  background: rgba(8, 8, 8, 0.58);
  backdrop-filter: blur(6px);
  border: 1px solid rgba(255, 255, 255, 0.14);
  font-family: ${So.body};
  font-weight: 600;
  font-size: 11px;
  line-height: 1.4;
  letter-spacing: 0.2px;
  color: rgba(255, 255, 255, 0.92);
  font-variant-numeric: tabular-nums;
  pointer-events: none;
`;function zc({value:e,min:t,max:n,onChange:r,imageFor:o}){const i=[];for(let l=t;l<=n;l++)i.push(l);return u.jsx(Xg,{children:i.map(l=>{const a=l===e;return u.jsxs(Jg,{type:"button",$active:a,title:`#${l}`,onClick:()=>r(l),children:[u.jsx(qg,{$active:a}),u.jsx(Up,{children:l}),u.jsx(ey,{children:u.jsx(ty,{src:o(l),alt:"",loading:"lazy",onError:Hg})})]},l)})})}const Xg=x.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
`,Jg=x.button`
  position: relative;
  aspect-ratio: 3 / 4;
  padding: 0;
  cursor: pointer;
  border: none;
  border-radius: ${tt.sm};
  overflow: hidden; /* crop the head shot's baked-in transparent margin (below) */
  background: linear-gradient(180deg, rgba(217, 217, 217, 0.2) 0%, rgba(115, 115, 115, 0.1) 100%);
  transition: transform 0.12s ease;
  &:active { transform: scale(0.97); }

  &::before,
  &::after {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: inherit;
    padding: 1px;
    -webkit-mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    -webkit-mask-composite: xor;
    mask-composite: exclude;
    pointer-events: none;
  }
  &::before {
    background: linear-gradient(to top, rgba(217, 217, 217, 0.65) 0%, rgba(217, 217, 217, 0) 72%);
  }
  &::after {
    background: linear-gradient(to top, rgba(var(--accent-rgb), 0.95) 0%, rgba(var(--accent-rgb), 0) 72%);
    opacity: ${e=>e.$active?1:0};
    transition: opacity 0.2s ease;
  }

  img { transition: transform 0.3s cubic-bezier(0.2, 0.7, 0.2, 1); }
  &:hover img { transform: scale(1.08); }
`,qg=x.div`
  position: absolute;
  inset: 0;
  border-radius: inherit;
  pointer-events: none;
  background: linear-gradient(0deg, rgba(var(--accent-rgb), 0.2), rgba(var(--accent-rgb), 0.06));
  opacity: ${e=>e.$active?1:0};
  transition: opacity 0.2s ease;
`,ey=x.div`
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
`,ty=x.img`
  /* head shots have ~18% transparent padding baked in; >100% + the card's
     overflow:hidden crops that dead space so the face/hair reads bigger. */
  max-width: 108%;
  max-height: 108%;
  object-fit: contain;
  filter: drop-shadow(0 8px 18px rgba(0, 0, 0, 0.5));
`,ny=e=>`https://docs.fivem.net/peds/${e.toLowerCase()}.webp`;function ry(){const{t:e,settings:t,data:n,setData:r,setSettings:o}=Ge(),[i,l]=j.useState(""),a=t?.ped.model.items??[],s=j.useMemo(()=>{const h=i.trim().toLowerCase();return h?a.filter(f=>f.toLowerCase().includes(h)):a},[a,i]);if(!t||!n)return null;const c=Math.max(0,a.indexOf(n.model));async function m(h){const f=await xe("appearance_change_model",h);f?.appearanceData&&r(()=>f.appearanceData),f?.appearanceSettings&&o(()=>f.appearanceSettings)}return u.jsxs(u.Fragment,{children:[u.jsx(qt,{children:e("ped.model")}),u.jsx(mn,{children:u.jsx(yt,{value:c,min:0,max:a.length-1,onChange:h=>m(a[h]),format:h=>a[h]??"—"})}),a.length>1&&u.jsxs(u.Fragment,{children:[u.jsx(wg,{value:i,onChange:l,placeholder:e("ped.search")}),u.jsx(Wg,{items:s.map(h=>({id:h,name:h,active:h===n.model,image:ny(h)})),onSelect:h=>m(String(h)),emptyLabel:e("ped.noResults")})]})]})}function oy(){const{t:e,data:t,settings:n,setData:r}=Ge();if(!t||!n)return null;const o=t.headBlend,i=n.headBlend;function l(a){r(s=>{const c={...s.headBlend,...a};return xe("appearance_change_head_blend",c),{...s,headBlend:c}})}return u.jsxs(u.Fragment,{children:[u.jsxs(mn,{children:[u.jsx(qt,{children:e("headBlend.shape.title")}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.shape.firstOption")}),u.jsx(yt,{value:o.shapeFirst,min:i.shapeFirst.min,max:i.shapeFirst.max,onChange:a=>l({shapeFirst:a})})]}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.shape.secondOption")}),u.jsx(yt,{value:o.shapeSecond,min:i.shapeSecond.min,max:i.shapeSecond.max,onChange:a=>l({shapeSecond:a})})]}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.shape.mix")}),u.jsx(Wr,{center:!0,value:o.shapeMix,min:i.shapeMix.min,max:i.shapeMix.max,step:i.shapeMix.factor??.1,onChange:a=>l({shapeMix:a})})]})]}),u.jsxs(mn,{children:[u.jsx(qt,{children:e("headBlend.skin.title")}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.skin.firstOption")}),u.jsx(yt,{value:o.skinFirst,min:i.skinFirst.min,max:i.skinFirst.max,onChange:a=>l({skinFirst:a})})]}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.skin.secondOption")}),u.jsx(yt,{value:o.skinSecond,min:i.skinSecond.min,max:i.skinSecond.max,onChange:a=>l({skinSecond:a})})]}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.skin.mix")}),u.jsx(Wr,{center:!0,value:o.skinMix,min:i.skinMix.min,max:i.skinMix.max,step:i.skinMix.factor??.1,onChange:a=>l({skinMix:a})})]})]}),u.jsxs(mn,{children:[u.jsx(qt,{children:e("headBlend.race.title")}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.race.shape")}),u.jsx(yt,{value:o.shapeThird,min:i.shapeThird.min,max:i.shapeThird.max,onChange:a=>l({shapeThird:a})})]}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.race.skin")}),u.jsx(yt,{value:o.skinThird,min:i.skinThird.min,max:i.skinThird.max,onChange:a=>l({skinThird:a})})]}),u.jsxs(rt,{children:[u.jsx($e,{children:e("headBlend.race.mix")}),u.jsx(Wr,{center:!0,value:o.thirdMix,min:i.thirdMix.min,max:i.thirdMix.max,step:i.thirdMix.factor??.1,onChange:a=>l({thirdMix:a})})]})]})]})}const iy=[{id:11,configKey:"jackets",labelKey:"components.jackets",camera:"body"},{id:8,configKey:"shirts",labelKey:"components.shirt",camera:"body"},{id:4,configKey:"lowerBody",labelKey:"components.lowerBody",camera:"legs"},{id:6,configKey:"shoes",labelKey:"components.shoes",camera:"bottom"},{id:3,configKey:"upperBody",labelKey:"components.upperBody",camera:"body"},{id:9,configKey:"bodyArmor",labelKey:"components.bodyArmor",camera:"body"},{id:7,configKey:"scarfAndChains",labelKey:"components.scarfAndChains",camera:"body"},{id:5,configKey:"bags",labelKey:"components.bags",camera:"body"},{id:10,configKey:"decals",labelKey:"components.decals",camera:"body"},{id:1,configKey:"masks",labelKey:"components.mask",camera:"head"}],ly=[{id:0,configKey:"hats",labelKey:"props.hats",camera:"head"},{id:1,configKey:"glasses",labelKey:"props.glasses",camera:"head"},{id:2,configKey:"ear",labelKey:"props.ear",camera:"head"},{id:6,configKey:"watches",labelKey:"props.watches",camera:"body"},{id:7,configKey:"bracelets",labelKey:"props.bracelets",camera:"body"}],ay=[{titleKey:"faceFeatures.nose.title",title:"Nose",x:{key:"noseWidth",minLabel:"Narrow",maxLabel:"Wide"},y:{key:"nosePeakHigh",minLabel:"Low",maxLabel:"High"}},{title:"Nose Profile",x:{key:"noseBoneHigh",minLabel:"Long",maxLabel:"Short"},y:{key:"noseBoneTwist",minLabel:"Straight",maxLabel:"Curved"}},{title:"Nose Tip",x:{key:"nosePeakSize",minLabel:"Short",maxLabel:"Long"},y:{key:"nosePeakLowering",minLabel:"Low",maxLabel:"High"}},{titleKey:"faceFeatures.eyebrows.title",title:"Eyebrows",x:{key:"eyeBrownForward",minLabel:"Outer",maxLabel:"Inner"},y:{key:"eyeBrownHigh",minLabel:"Low",maxLabel:"High"}},{title:"Cheekbones",x:{key:"cheeksBoneWidth",minLabel:"Hollow",maxLabel:"Full"},y:{key:"cheeksBoneHigh",minLabel:"Low",maxLabel:"High"}},{titleKey:"faceFeatures.cheeks.title",title:"Cheeks",y:{key:"cheeksWidth",minLabel:"Hollow",maxLabel:"Full"}},{title:"Eyes",x:{key:"eyesOpening",minLabel:"Open",maxLabel:"Closed"}},{title:"Lips",x:{key:"lipsThickness",minLabel:"Thick",maxLabel:"Thin"}},{titleKey:"faceFeatures.jaw.title",title:"Jaw",x:{key:"jawBoneWidth",minLabel:"Narrow",maxLabel:"Wide"},y:{key:"jawBoneBackSize",minLabel:"Square",maxLabel:"Round"}},{titleKey:"faceFeatures.chin.title",title:"Chin",x:{key:"chinBoneLenght",minLabel:"Deep",maxLabel:"Out"},y:{key:"chinBoneLowering",minLabel:"Low",maxLabel:"High"}},{title:"Chin Shape",x:{key:"chinBoneSize",minLabel:"Round",maxLabel:"Square"},y:{key:"chinHole",minLabel:"Low",maxLabel:"High"}},{titleKey:"faceFeatures.neck.title",title:"Neck",x:{key:"neckThickness",minLabel:"Thin",maxLabel:"Thick"},line:!0}],sy=["blemishes","beard","eyebrows","ageing","makeUp","blush","complexion","sunDamage","lipstick","moleAndFreckles","chestHair","bodyBlemishes"],uy={blemishes:0,beard:1,eyebrows:2,ageing:3,makeUp:4,blush:5,complexion:6,sunDamage:7,lipstick:8,moleAndFreckles:9,chestHair:10,bodyBlemishes:11},cy=["ZONE_HEAD","ZONE_TORSO","ZONE_LEFT_ARM","ZONE_RIGHT_ARM","ZONE_LEFT_LEG","ZONE_RIGHT_LEG"],dy=["Green","Emerald","Light Blue","Ocean Blue","Light Brown","Dark Brown","Hazel","Dark Gray","Light Gray","Pink","Yellow","Purple","Blackout","Shades of Gray","Tequila Sunrise","Atomic","Warp","ECola","Space Ranger","Ying Yang","Bullseye","Lizard","Dragon","Extra Terrestrial","Goat","Smiley","Possessed","Demon","Infected","Alien","Undead","Zombie"],fy={min:-1,max:1,factor:.1};function py(){const{t:e,data:t,settings:n,setData:r}=Ge();if(!t||!n)return null;function o(l){r(a=>{const s={...a.faceFeatures,...l};return xe("appearance_change_face_feature",s),{...a,faceFeatures:s}})}const i=l=>{if(!l)return;const a=n.faceFeatures[l.key]??fy;return{value:t.faceFeatures[l.key]??0,min:a.min,max:a.max,step:a.factor??.1,minLabel:l.minLabel,maxLabel:l.maxLabel}};return u.jsx(hy,{children:ay.map((l,a)=>u.jsxs(j.Fragment,{children:[a>0&&u.jsx(gy,{}),u.jsxs(my,{children:[u.jsx(qt,{children:l.titleKey?e(l.titleKey):l.title}),u.jsx(Mg,{x:i(l.x),y:i(l.y),line:l.line,onChange:s=>{const c={};s.x!==void 0&&l.x&&(c[l.x.key]=s.x),s.y!==void 0&&l.y&&(c[l.y.key]=s.y),o(c)}})]})]},l.titleKey??l.title))})}const hy=x.div`
  display: flex;
  flex-direction: column;
  gap: 24px;
`,my=x.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
`,gy=x.div`
  align-self: center;
  width: 64%;
  height: 2px;
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0) 0%,
    rgba(255, 255, 255, 0.44) 50%,
    rgba(255, 255, 255, 0) 100%
  );
`,{color:Wp,font:yy,radius:xy,layout:Dl}=le,vy=Js`
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: none; }
`;function wy({value:e,min:t,max:n,step:r,onChange:o}){const{t:i}=Ge();return u.jsxs(ky,{children:[u.jsx(Sy,{children:i("headOverlays.opacity")}),u.jsx($y,{children:u.jsx(Wr,{value:e,min:t,max:n,step:r,onChange:o,format:l=>`${Math.round(l*100)}%`})})]})}const ky=x.div`
  position: absolute;
  left: ${Dl.panelX+Dl.contentPad}px;
  width: ${Dl.contentWidth}px;
  bottom: 122px;
  height: 52px;
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 0 18px;
  border-radius: ${xy.md};
  background: rgba(14, 14, 14, 0.86);
  border: 1px solid ${Wp.borderSoft};
  backdrop-filter: blur(10px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.5);
  animation: ${vy} 0.2s ease both;
`,Sy=x.div`
  flex: 0 0 auto;
  font-family: ${yy.body};
  font-size: 14px;
  font-weight: 600;
  color: ${Wp.text};
  white-space: nowrap;
`,$y=x.div`
  flex: 1;
  min-width: 0;
`;function by(){const{t:e,data:t,settings:n,setData:r,setSettings:o,config:i}=Ge(),l=j.useRef(null),[a,s]=j.useState(null),[c,m]=j.useState(null);if(j.useLayoutEffect(()=>{s(l.current?.closest(".app-stage")??null)},[]),!t||!n)return null;async function h(y){const C={...t.hair,...y};r($=>({...$,hair:C}));const b=await xe("appearance_change_hair",C);b&&o($=>({...$,hair:b}))}function f(y,C){r(b=>{const $=b.headOverlays[y]??{style:0,opacity:0,color:0,secondColor:0},R={...b.headOverlays,[y]:{...$,...C}};return xe("appearance_change_head_overlay",R),{...b,headOverlays:R}})}function w(y){r(C=>(xe("appearance_change_eye_color",y),{...C,eyeColor:y}))}const v=t.hair,k=n.hair,_=tu(t.model),p=(y,C)=>{f(y,C),m(y)},d=c?n.headOverlays[c]:void 0,g=c?t.headOverlays[c]:void 0,S=a&&c&&d?or.createPortal(u.jsx(wy,{value:g?.opacity??0,min:d.opacity.min,max:d.opacity.max,step:d.opacity.factor??.1,onChange:y=>f(c,{opacity:y})}),a):null;return u.jsxs("div",{ref:l,children:[u.jsxs(mn,{children:[u.jsx(qt,{children:e("headOverlays.hair.title")}),u.jsx($e,{style:{marginBottom:8},children:e("headOverlays.hair.style")}),u.jsx(zc,{value:v.style,min:k.style.min,max:k.style.max,imageFor:y=>Z1(_,y),onChange:y=>h({style:y,texture:0})}),u.jsxs(rt,{style:{marginTop:14},children:[u.jsx($e,{children:e("headOverlays.hair.texture")}),u.jsx(yt,{value:v.texture,min:k.texture.min,max:k.texture.max,onChange:y=>h({texture:y})})]}),u.jsx($e,{style:{marginBottom:8},children:e("headOverlays.hair.color")}),u.jsx(Fl,{items:k.color.items,value:v.color,onChange:y=>h({color:y})}),u.jsx($e,{style:{margin:"14px 0 8px"},children:e("headOverlays.hair.highlight")}),u.jsx(Fl,{items:k.highlight.items,value:v.highlight,onChange:y=>h({highlight:y})})]}),sy.map(y=>{const C=n.headOverlays[y];if(!C||!og(_,y,i?.allowChestHairFemale))return null;const b=t.headOverlays[y]??{style:0,color:0};return u.jsxs(j.Fragment,{children:[u.jsx(Tc,{}),u.jsxs(mn,{children:[u.jsx(qt,{children:e(`headOverlays.${y}`)}),ng(_,y)?u.jsxs(u.Fragment,{children:[u.jsx($e,{style:{marginBottom:8},children:e("headOverlays.style")}),u.jsx(zc,{value:b.style,min:C.style.min,max:C.style.max,imageFor:$=>X1(_,uy[y],$),onChange:$=>p(y,{style:$})})]}):u.jsxs(rt,{children:[u.jsx($e,{children:e("headOverlays.style")}),u.jsx(yt,{value:b.style,min:C.style.min,max:C.style.max,onChange:$=>p(y,{style:$})})]}),C.color&&u.jsxs(u.Fragment,{children:[u.jsx($e,{style:{margin:"14px 0 8px"},children:e("headOverlays.color")}),u.jsx(Fl,{items:C.color.items,value:b.color,onChange:$=>f(y,{color:$})})]})]})]},y)}),u.jsx(Tc,{}),u.jsxs(mn,{children:[u.jsx(qt,{children:e("headOverlays.eyeColor")}),u.jsx(yt,{value:t.eyeColor,min:n.eyeColor.min,max:n.eyeColor.max,onChange:w,format:y=>dy[y]??String(y)})]}),S]})}const{color:Ut,font:Vp,radius:Gp,layout:Hl}=le;function Ac(e,t,n){let r=e.texture+t;r>e.max&&(r=e.min),r<e.min&&(r=e.max),n(r)}const Cy=Js`
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: none; }
`;function _y({selection:e,onTexture:t}){const n=e.max-e.min+1,r=e.texture-e.min+1;return u.jsxs(Ey,{children:[u.jsxs(jy,{children:[e.category," ",u.jsxs("em",{children:["#",e.drawable]})]}),u.jsxs(Ty,{children:[u.jsx(Ic,{type:"button","aria-label":"Previous colour",onClick:()=>Ac(e,-1,t),children:u.jsx(Ri,{size:14,style:{transform:"scaleX(-1)"}})}),u.jsxs(Ly,{children:[r," / ",n]}),u.jsx(Ic,{type:"button","aria-label":"Next colour",onClick:()=>Ac(e,1,t),children:u.jsx(Ri,{size:14})})]})]})}const Ey=x.div`
  position: absolute;
  left: ${Hl.panelX+Hl.contentPad}px;
  width: ${Hl.contentWidth}px;
  bottom: 122px;
  height: 52px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding: 0 14px 0 16px;
  border-radius: ${Gp.md};
  background: rgba(14, 14, 14, 0.86);
  border: 1px solid ${Ut.borderSoft};
  backdrop-filter: blur(10px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.5);
  animation: ${Cy} 0.2s ease both;
`,jy=x.div`
  min-width: 0;
  font-family: ${Vp.body};
  font-size: 14px;
  font-weight: 600;
  color: ${Ut.text};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  em { font-style: normal; font-weight: 400; color: ${Ut.textMuted}; margin-left: 4px; }
`,Ty=x.div`
  display: flex;
  align-items: center;
  gap: 6px;
  flex: 0 0 auto;
`,Ic=x.button`
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border-radius: ${Gp.sm};
  border: 1px solid ${Ut.borderSoft};
  background: ${Ut.surface05};
  color: #fff;
  transition: background 0.12s ease, border-color 0.12s ease;
  &:hover { background: ${Ut.accent}; border-color: ${Ut.accent}; }
`,Ly=x.div`
  min-width: 46px;
  text-align: center;
  font-family: ${Vp.body};
  font-size: 13px;
  color: ${Ut.text};
  font-variant-numeric: tabular-nums;
`,{color:pt,font:rl,radius:hr,layout:Bc}=le,Py=(e,t)=>25+(e*7+t*13)%12*25,ru=e=>{e.currentTarget.style.display="none"};function Ny(e){const{t,config:n,data:r,settings:o,setData:i,setSettings:l}=Ge(),a=e==="component",s=j.useMemo(()=>{if(!n)return[];const f=a?iy:ly,w=a?n.componentConfig:n.propConfig;return f.filter(v=>w?.[v.configKey]!==!1)},[a,n]);if(!r||!o)return null;const c=tu(r.model),m=[];for(const f of s){const w=a?r.components.find(S=>S.component_id===f.id):r.props.find(S=>S.prop_id===f.id),v=a?o.components.find(S=>S.component_id===f.id):o.props.find(S=>S.prop_id===f.id);if(!w||!v)continue;const k=w.drawable,_=w.texture,p=v.drawable,d=v.texture,g=[];for(let S=p.min;S<=p.max;S++){const y=!a&&S===-1;g.push({id:S,label:y?t("app.none"):`#${S}`,image:y?void 0:Y1(c,e,f.id,S),price:!y&&pr()?Py(f.id,S):void 0,active:S===k})}m.push({id:f.id,key:String(f.id),label:t(f.labelKey),image:Q1(f.configKey),camera:f.camera,items:g,drawable:k,texture:_,textureMin:d.min,textureMax:d.max})}return{kind:e,sections:m,apply:(f,w,v)=>{a?(i(k=>({...k,components:k.components.map(_=>_.component_id===f?{..._,drawable:w,texture:v}:_)})),xe("appearance_change_component",{component_id:f,drawable:w,texture:v}).then(k=>{k&&l(_=>({..._,components:_.components.map(p=>p.component_id===f?k:p)}))})):(i(k=>({...k,props:k.props.map(_=>_.prop_id===f?{..._,drawable:w,texture:v}:_)})),xe("appearance_change_prop",{prop_id:f,drawable:w,texture:v}).then(k=>{k&&l(_=>({..._,props:_.props.map(p=>p.prop_id===f?k:p)}))}))}}}function Oy(e,t){const[n,r]=j.useState(t[0]??null),o=t.join(",");return j.useEffect(()=>{if(!e)return;const i=o.split(","),l=new Set,a=new IntersectionObserver(s=>{for(const m of s){const h=m.target.dataset.sec;h&&(m.isIntersecting?l.add(h):l.delete(h))}const c=i.find(m=>l.has(m));c&&r(c)},{root:e,rootMargin:"-8px 0px -62% 0px",threshold:0});return e.querySelectorAll("[data-sec]").forEach(s=>a.observe(s)),()=>a.disconnect()},[e,o]),n}function Ry(e,t){e?.querySelector(`[data-sec='${t}']`)?.scrollIntoView({behavior:"smooth",block:"start"})}function My(e){let t=e.parentElement;for(;t;){const n=getComputedStyle(t).overflowY;if(n==="auto"||n==="scroll")return t;t=t.parentElement}return null}function zy({item:e}){return e.image?u.jsx(Ay,{src:e.image,alt:"",loading:"lazy",onError:ru}):null}const Ay=x.img`
  max-width: 92%;
  max-height: 92%;
  object-fit: contain;
  filter: drop-shadow(0 8px 18px rgba(0, 0, 0, 0.5));
`;function Iy({label:e,image:t,count:n,kind:r}){const{t:o}=Ge(),i=r==="prop"?"props":"components";return u.jsxs(By,{children:[u.jsx(Fy,{children:t&&u.jsx("img",{src:t,alt:"",onError:ru})}),u.jsx(Dy,{}),u.jsxs(Hy,{children:[u.jsx(Uy,{children:o(`${i}.kicker`)}),u.jsx(Wy,{children:e}),u.jsxs(Vy,{children:[u.jsx(Fc,{children:o("app.optionsCount",n)}),u.jsx(Fc,{children:o(`${i}.chip`)})]})]})]})}const By=x.div`
  display: flex;
  align-items: center;
  gap: 18px;
  height: 156px;
  padding: 0 20px;
  margin-bottom: 16px;
  border-radius: ${hr.lg};
  border: 1px solid ${pt.borderSoft};
  background:
    radial-gradient(70% 120% at 12% 50%, rgba(var(--accent-rgb), 0.18), transparent 60%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.04), rgba(0, 0, 0, 0.36));
`,Fy=x.div`
  flex: 0 0 128px;
  height: 128px;
  display: flex;
  align-items: center;
  justify-content: center;
  img { max-width: 100%; max-height: 100%; object-fit: contain; filter: drop-shadow(0 12px 24px rgba(0, 0, 0, 0.6)); }
`,Dy=x.div`
  flex: 0 0 2px;
  align-self: stretch;
  margin: 28px 0;
  background: linear-gradient(180deg, transparent, ${pt.accent}, transparent);
`,Hy=x.div`
  flex: 1;
  min-width: 0;
`,Uy=x.div`
  font-family: ${rl.body};
  font-size: 11px;
  letter-spacing: 2px;
  text-transform: uppercase;
  color: ${pt.accent};
`,Wy=x.div`
  margin-top: 6px;
  font-family: ${rl.body};
  font-weight: 700;
  font-size: 30px;
  line-height: 1;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  color: ${pt.text};
`,Vy=x.div`
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
`,Fc=x.span`
  padding: 5px 11px;
  border-radius: ${hr.pill};
  font-size: 11px;
  letter-spacing: 0.3px;
  color: ${pt.textLabel};
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid ${pt.borderSoft};
`,Dc=12;function Gy({items:e,onPick:t,scrollRoot:n}){const r=[];for(let o=0;o<e.length;o+=Dc)r.push(e.slice(o,o+Dc));return u.jsx(Yy,{children:r.map((o,i)=>u.jsx(Ky,{items:o,onPick:t,scrollRoot:n},i))})}function Ky({items:e,onPick:t,scrollRoot:n}){const{t:r}=Ge(),o=j.useRef(null),[i,l]=j.useState(!1);return j.useLayoutEffect(()=>{const a=o.current;if(!a||!n)return;const s=700,c=a.getBoundingClientRect(),m=n.getBoundingClientRect();l(c.top<=m.bottom+s&&c.bottom>=m.top-s);const h=new IntersectionObserver(f=>l(f[0].isIntersecting),{root:n,rootMargin:`${s}px 0px ${s}px 0px`,threshold:0});return h.observe(a),()=>h.disconnect()},[n]),u.jsx(Qy,{ref:o,children:i?e.map(a=>u.jsxs(Xy,{type:"button",$active:!!a.active,onClick:()=>t(a),children:[u.jsx(qy,{$active:!!a.active}),u.jsx(Jy,{children:u.jsx(zy,{item:a})}),a.id>=0&&u.jsx(Up,{children:a.id}),a.id<0&&u.jsx(tx,{children:r("app.none")}),a.price!==void 0&&u.jsxs(ex,{children:[u.jsx("i",{children:"$"}),a.price]})]},a.id)):e.map(a=>u.jsx(Zy,{},a.id))})}const Yy=x.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
`,Qy=x.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
`,Zy=x.div`
  aspect-ratio: 3 / 4;
  border-radius: ${hr.sm};
  background: linear-gradient(180deg, rgba(217, 217, 217, 0.06) 0%, rgba(115, 115, 115, 0.03) 100%);
`,Xy=x.button`
  position: relative;
  aspect-ratio: 3 / 4;
  padding: 0;
  cursor: pointer;
  border: none;
  border-radius: ${hr.sm};
  background: linear-gradient(180deg, rgba(217, 217, 217, 0.2) 0%, rgba(115, 115, 115, 0.1) 100%);
  transition: transform 0.12s ease;
  &:active { transform: scale(0.97); }

  /* Two masked 1px rings sharing the same "gray at the bottom, fading to
     transparent toward the top" shape: ::before is the gray border (always),
     ::after is the accent border that cross-fades in (via opacity) when the card
     is selected — so selection animates instead of snapping. The masks cut out
     the interior so only the 1px perimeter shows. */
  &::before,
  &::after {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: inherit;
    padding: 1px;
    -webkit-mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    -webkit-mask-composite: xor;
    mask-composite: exclude;
    pointer-events: none;
  }
  &::before {
    background: linear-gradient(to top, rgba(217, 217, 217, 0.65) 0%, rgba(217, 217, 217, 0) 72%);
  }
  &::after {
    background: linear-gradient(to top, rgba(var(--accent-rgb), 0.95) 0%, rgba(var(--accent-rgb), 0) 72%);
    opacity: ${e=>e.$active?1:0};
    transition: opacity 0.2s ease;
  }

  img { transition: transform 0.3s cubic-bezier(0.2, 0.7, 0.2, 1); }
  &:hover img { transform: scale(1.08); }
`,Jy=x.div`
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
`,qy=x.div`
  position: absolute;
  inset: 0;
  border-radius: inherit;
  pointer-events: none;
  background: linear-gradient(0deg, rgba(var(--accent-rgb), 0.2), rgba(var(--accent-rgb), 0.06));
  opacity: ${e=>e.$active?1:0};
  transition: opacity 0.2s ease;
`,ex=x.div`
  position: absolute;
  left: 7px;
  bottom: 7px;
  display: inline-flex;
  align-items: baseline;
  gap: 2px;
  padding: 3px 10px;
  border-radius: ${hr.pill};
  background: rgba(8, 8, 8, 0.6);
  backdrop-filter: blur(6px);
  border: 1px solid rgba(255, 255, 255, 0.12);
  font-family: ${rl.body};
  font-weight: 700;
  font-size: 12px;
  letter-spacing: 0.2px;
  color: #fff;
  font-variant-numeric: tabular-nums;
  i { font-style: normal; font-weight: 600; font-size: 10px; color: ${pt.accent}; }
`,tx=x.div`
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: ${rl.body};
  font-size: 13px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  color: ${pt.textMuted};
`;function nx({model:e,scrollRoot:t}){const{setCamera:n}=Ge(),r=e.sections.map(l=>l.key),o=Oy(t,r),i=l=>{Ry(t,l.key),n(l.camera)};return u.jsx(rx,{children:e.sections.map(l=>u.jsxs(ox,{type:"button",$active:l.key===o,"aria-label":l.label,onClick:()=>i(l),children:[u.jsx("img",{src:l.image,alt:"",onError:ru}),u.jsx(Kp,{children:l.label})]},l.key))})}const rx=x.div`
  position: absolute;
  left: ${Bc.panelX+Bc.panelWidth+14}px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 40;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
  padding: 4px;
`,Kp=x.span`
  position: absolute;
  left: calc(100% + 12px);
  top: 50%;
  transform: translateY(-50%) translateX(-4px);
  padding: 5px 11px;
  border-radius: ${hr.pill};
  background: rgba(0, 0, 0, 0.82);
  border: 1px solid ${pt.borderSoft};
  font-size: 11px;
  letter-spacing: 0.3px;
  color: #fff;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.14s ease, transform 0.14s ease;
`,ox=x.button`
  position: relative;
  flex: 0 0 auto;
  width: 58px;
  height: 58px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid ${e=>e.$active?pt.accent:"rgba(255,255,255,0.14)"};
  background: ${e=>e.$active?"rgba(var(--accent-rgb),0.55)":"rgba(18,18,18,0.72)"};
  box-shadow: ${e=>e.$active?"0 0 20px rgba(var(--accent-rgb),0.6)":"0 6px 16px rgba(0,0,0,0.45)"};
  backdrop-filter: blur(8px);
  transition: transform 0.16s ease, border-color 0.16s ease, box-shadow 0.16s ease, background 0.16s ease;
  img { width: 42px; height: 42px; object-fit: contain; opacity: ${e=>e.$active?1:.68}; transition: opacity 0.16s ease; }
  &:hover { transform: scale(1.09); border-color: ${e=>e.$active?pt.accent:"rgba(255,255,255,0.36)"}; img { opacity: 1; } }
  &:hover ${Kp} { opacity: 1; transform: translateY(-50%) translateX(0); }
`;function ix({section:e,kind:t,onPick:n,scrollRoot:r}){return u.jsxs(lx,{"data-sec":e.key,children:[u.jsx(Iy,{label:e.label,image:e.image,count:e.items.length,kind:t}),u.jsx(Gy,{items:e.items,onPick:n,scrollRoot:r})]})}function Hc({kind:e}){const t=Ny(e),n=j.useRef(null),[r,o]=j.useState(null),[i,l]=j.useState(null),[a,s]=j.useState(null);if(j.useLayoutEffect(()=>{const f=n.current;f&&(o(My(f)),l(f.closest(".app-stage")))},[]),!t)return null;const c=(f,w)=>{const v=t.sections.find(_=>_.id===f),k=w.id<0?-1:v&&v.drawable===w.id?v.texture:0;t.apply(f,w.id,k),s(f)},m=a!=null?t.sections.find(f=>f.id===a):void 0;let h=null;if(i&&m&&m.drawable>=0&&m.textureMax>m.textureMin){const f=m.id,w={category:m.label,drawable:m.drawable,texture:m.texture,min:m.textureMin,max:m.textureMax};h=or.createPortal(u.jsx(_y,{selection:w,onTexture:v=>t.apply(f,w.drawable,v)}),i)}return u.jsxs("div",{ref:n,children:[t.sections.map(f=>u.jsx(ix,{section:f,kind:e,scrollRoot:r,onPick:w=>c(f.id,w)},f.key)),i&&or.createPortal(u.jsx(nx,{model:t,scrollRoot:r}),i),h]})}const lx=x.div`
  margin-bottom: 32px;
  scroll-margin-top: 16px;
`,{color:q,font:ol,radius:Cn,layout:Vr}=le,Yp=e=>{e.currentTarget.style.display="none"},ax={ZONE_HEAD:"head",ZONE_TORSO:"body",ZONE_LEFT_ARM:"body",ZONE_RIGHT_ARM:"body",ZONE_LEFT_LEG:"legs",ZONE_RIGHT_LEG:"legs"},Uc=(e,t)=>e.name===t.name&&e.collection===t.collection;function sx(e,t){const[n,r]=j.useState(t[0]??null),o=t.join(",");return j.useEffect(()=>{if(!e)return;const i=o.split(","),l=new Set,a=new IntersectionObserver(s=>{for(const m of s){const h=m.target.dataset.sec;h&&(m.isIntersecting?l.add(h):l.delete(h))}const c=i.find(m=>l.has(m));c&&r(c)},{root:e,rootMargin:"-8px 0px -62% 0px",threshold:0});return e.querySelectorAll("[data-sec]").forEach(s=>a.observe(s)),()=>a.disconnect()},[e,o]),n}function ux(e,t){e?.querySelector(`[data-sec='${t}']`)?.scrollIntoView({behavior:"smooth",block:"start"})}function cx(e){let t=e.parentElement;for(;t;){const n=getComputedStyle(t).overflowY;if(n==="auto"||n==="scroll")return t;t=t.parentElement}return null}function dx(){const{t:e,data:t,settings:n,setData:r,setCamera:o}=Ge(),i=j.useRef(null),[l,a]=j.useState(null),[s,c]=j.useState(null),m=n?.tattoos.opacity??{min:.1,max:1,factor:.1},[h,f]=j.useState(m.max);j.useLayoutEffect(()=>{const y=i.current;y&&(a(cx(y)),c(y.closest(".app-stage")))},[]);const w=j.useMemo(()=>!t||!n?[]:cy.filter(y=>Array.isArray(n.tattoos.items[y])&&n.tattoos.items[y].length>0).map(y=>({key:y,label:e(`tattoos.items.${y}`),image:eg(y),camera:ax[y]??"body",available:n.tattoos.items[y]??[],applied:t.tattoos[y]??[]})),[t,n,e]);if(!t||!n||!w.length)return null;const v=tu(t.model),k=Object.values(t.tattoos).reduce((y,C)=>y+(C?.length??0),0),_=y=>{xe("appearance_apply_tattoo",{updatedTattoos:y})},p=(y,C)=>{const b=t.tattoos[y]??[],$=b.findIndex(D=>Uc(D,C)),R=$!==-1?b.filter((D,W)=>W!==$):[...b,{...C,opacity:h}],O={...t.tattoos,[y]:R};_(O),r(D=>({...D,tattoos:O}))},d=y=>{f(y);let C=!1;const b={};for(const[$,R]of Object.entries(t.tattoos))b[$]=(R??[]).map(O=>(C=!0,{...O,opacity:y}));C&&_(b),r($=>({...$,tattoos:b}))},g=()=>{const y={};xe("appearance_delete_tattoo",y),r(C=>({...C,tattoos:y}))},S=y=>{ux(l,y.key),o(y.camera)};return u.jsxs(mx,{ref:i,children:[w.map(y=>u.jsxs(gx,{"data-sec":y.key,children:[u.jsx(fx,{zone:y}),y.available.length===0?u.jsx(Rx,{children:"—"}):u.jsx(Cx,{children:y.available.map(C=>u.jsx(hx,{tat:C,gender:v,on:y.applied.some(b=>Uc(b,C)),onToggle:()=>p(y.key,C)},`${C.collection}:${C.name}`))})]},y.key)),k>0&&u.jsx(Mx,{onClick:g,children:e("tattoos.deleteAll")}),u.jsx(zx,{children:e("tattoos.hint")}),s&&or.createPortal(u.jsx(px,{zones:w,scrollRoot:l,onJump:S}),s),s&&or.createPortal(u.jsxs(Bx,{children:[u.jsx(Fx,{children:e("tattoos.opacity")}),u.jsx(Wr,{value:h,min:m.min,max:m.max,step:m.factor??.1,onChange:d})]}),s)]})}function fx({zone:e}){const{t}=Ge();return u.jsxs(yx,{children:[u.jsx(xx,{children:u.jsx("img",{src:e.image,alt:"",onError:Yp})}),u.jsx(vx,{}),u.jsxs(wx,{children:[u.jsx(kx,{children:t("tattoos.title")}),u.jsx(Sx,{children:e.label}),u.jsxs($x,{children:[u.jsx(Qp,{children:t("tattoos.designsCount",e.available.length)}),e.applied.length>0&&u.jsx(bx,{children:t("tattoos.appliedCount",e.applied.length)})]})]})]})}function px({zones:e,scrollRoot:t,onJump:n}){const r=sx(t,e.map(o=>o.key));return u.jsx(Ax,{children:e.map(o=>u.jsxs(Ix,{type:"button",$active:o.key===r,"aria-label":o.label,onClick:()=>n(o),children:[u.jsx("img",{src:o.image,alt:"",onError:Yp}),u.jsx(Zp,{children:o.label})]},o.key))})}function hx({tat:e,gender:t,on:n,onToggle:r}){const[o,i]=j.useState(!1),l=e.label||e.name;return u.jsxs(_x,{children:[u.jsxs(Ex,{type:"button",$active:n,title:l,onClick:r,children:[u.jsx(jx,{$active:n}),o?u.jsx(Px,{children:l}):u.jsx(Tx,{children:u.jsx(Lx,{src:J1(t,e.name),alt:"",loading:"lazy",onError:()=>i(!0)})}),n&&u.jsx(Nx,{"aria-hidden":!0,children:"✓"})]}),!o&&u.jsx(Ox,{$active:n,children:l})]})}const mx=x.div`
  padding-bottom: 84px;
`,gx=x.div`
  margin-bottom: 32px;
  scroll-margin-top: 16px;
`,yx=x.div`
  display: flex;
  align-items: center;
  gap: 18px;
  height: 156px;
  padding: 0 20px;
  margin-bottom: 16px;
  border-radius: ${Cn.lg};
  border: 1px solid ${q.borderSoft};
  background:
    radial-gradient(70% 120% at 12% 50%, rgba(var(--accent-rgb), 0.18), transparent 60%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.04), rgba(0, 0, 0, 0.36));
`,xx=x.div`
  flex: 0 0 128px;
  height: 128px;
  display: flex;
  align-items: center;
  justify-content: center;
  img { max-width: 100%; max-height: 100%; object-fit: contain; filter: drop-shadow(0 12px 24px rgba(0, 0, 0, 0.6)); }
`,vx=x.div`
  flex: 0 0 2px;
  align-self: stretch;
  margin: 28px 0;
  background: linear-gradient(180deg, transparent, ${q.accent}, transparent);
`,wx=x.div`
  flex: 1;
  min-width: 0;
`,kx=x.div`
  font-family: ${ol.body};
  font-size: 11px;
  letter-spacing: 2px;
  text-transform: uppercase;
  color: ${q.accent};
`,Sx=x.div`
  margin-top: 6px;
  font-family: ${ol.body};
  font-weight: 700;
  font-size: 30px;
  line-height: 1;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  color: ${q.text};
`,$x=x.div`
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
`,Qp=x.span`
  padding: 5px 11px;
  border-radius: ${Cn.pill};
  font-size: 11px;
  letter-spacing: 0.3px;
  color: ${q.textLabel};
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid ${q.borderSoft};
`,bx=x(Qp)`
  color: #fff;
  background: rgba(var(--accent-rgb), 0.18);
  border-color: ${q.accent};
  box-shadow: 0 0 12px rgba(var(--accent-rgb), 0.4);
`,Cx=x.div`
  display: grid;
  /* minmax(0, 1fr), not 1fr: 1fr's implicit auto-minimum sizes each track to its
     content, so a card with a long nowrap label widens its whole column and the
     grid goes uneven. Pinning the min to 0 keeps all three columns equal. */
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
`,_x=x.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
`,Ex=x.button`
  position: relative;
  aspect-ratio: 3 / 4;
  padding: 0;
  cursor: pointer;
  border: none;
  border-radius: ${Cn.sm};
  background: linear-gradient(180deg, rgba(217, 217, 217, 0.2) 0%, rgba(115, 115, 115, 0.1) 100%);
  transition: transform 0.12s ease;
  &:active { transform: scale(0.97); }

  &::before,
  &::after {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: inherit;
    padding: 1px;
    -webkit-mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    mask:
      linear-gradient(#fff 0 0) content-box,
      linear-gradient(#fff 0 0);
    -webkit-mask-composite: xor;
    mask-composite: exclude;
    pointer-events: none;
  }
  &::before {
    background: linear-gradient(to top, rgba(217, 217, 217, 0.65) 0%, rgba(217, 217, 217, 0) 72%);
  }
  &::after {
    background: linear-gradient(to top, rgba(var(--accent-rgb), 0.95) 0%, rgba(var(--accent-rgb), 0) 72%);
    opacity: ${e=>e.$active?1:0};
    transition: opacity 0.2s ease;
  }

  img { transition: transform 0.3s cubic-bezier(0.2, 0.7, 0.2, 1); }
  &:hover img { transform: scale(1.08); }
`,jx=x.div`
  position: absolute;
  inset: 0;
  border-radius: inherit;
  pointer-events: none;
  background: linear-gradient(0deg, rgba(var(--accent-rgb), 0.2), rgba(var(--accent-rgb), 0.06));
  opacity: ${e=>e.$active?1:0};
  transition: opacity 0.2s ease;
`,Tx=x.div`
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
`,Lx=x.img`
  max-width: 92%;
  max-height: 92%;
  object-fit: contain;
  filter: drop-shadow(0 8px 18px rgba(0, 0, 0, 0.5));
`,Px=x.span`
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 12px;
  text-align: center;
  font-size: 13px;
  line-height: 1.35;
  color: ${q.textMuted};
`,Nx=x.div`
  position: absolute;
  top: 6px;
  right: 6px;
  z-index: 2;
  width: 22px;
  height: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: ${q.accent};
  color: #fff;
  font-size: 12px;
  line-height: 1;
  box-shadow: 0 0 12px rgba(var(--accent-rgb), 0.7);
`,Ox=x.div`
  font-size: 12px;
  text-align: center;
  color: ${e=>e.$active?q.text:q.textMuted};
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
`,Rx=x.div`
  padding: 28px 16px;
  text-align: center;
  font-size: 13px;
  color: ${q.textFaint};
  border: 1px dashed ${q.border};
  border-radius: ${Cn.md};
`,Mx=x.button`
  margin-top: 4px;
  width: 100%;
  height: 40px;
  border-radius: ${Cn.md};
  border: 1px solid ${q.accent};
  background: ${q.accentFaint};
  color: ${q.accent};
  font-family: ${ol.body};
  font-size: 13px;
  letter-spacing: 1px;
  cursor: pointer;
  transition: all 0.12s ease;
  &:hover { background: ${q.accent}; color: #fff; }
`,zx=x.div`
  margin-top: 14px;
  font-size: 11px;
  color: ${q.textFaint};
  text-align: center;
`,Ax=x.div`
  position: absolute;
  left: ${Vr.panelX+Vr.panelWidth+14}px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 40;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
  padding: 4px;
`,Zp=x.span`
  position: absolute;
  left: calc(100% + 12px);
  top: 50%;
  transform: translateY(-50%) translateX(-4px);
  padding: 5px 11px;
  border-radius: ${Cn.pill};
  background: rgba(0, 0, 0, 0.82);
  border: 1px solid ${q.borderSoft};
  font-size: 11px;
  letter-spacing: 0.3px;
  color: #fff;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.14s ease, transform 0.14s ease;
`,Ix=x.button`
  position: relative;
  flex: 0 0 auto;
  width: 58px;
  height: 58px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid ${e=>e.$active?q.accent:"rgba(255,255,255,0.14)"};
  background: ${e=>e.$active?"rgba(var(--accent-rgb),0.55)":"rgba(18,18,18,0.72)"};
  box-shadow: ${e=>e.$active?"0 0 20px rgba(var(--accent-rgb),0.6)":"0 6px 16px rgba(0,0,0,0.45)"};
  backdrop-filter: blur(8px);
  transition: transform 0.16s ease, border-color 0.16s ease, box-shadow 0.16s ease, background 0.16s ease;
  img { width: 42px; height: 42px; object-fit: contain; opacity: ${e=>e.$active?1:.68}; transition: opacity 0.16s ease; }
  &:hover { transform: scale(1.09); border-color: ${e=>e.$active?q.accent:"rgba(255,255,255,0.36)"}; img { opacity: 1; } }
  &:hover ${Zp} { opacity: 1; transform: translateY(-50%) translateX(0); }
`,Bx=x.div`
  position: absolute;
  left: ${Vr.panelX+Vr.contentPad}px;
  width: ${Vr.contentWidth}px;
  bottom: 122px;
  height: 54px;
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 0 18px;
  border-radius: ${Cn.md};
  background: rgba(14, 14, 14, 0.86);
  border: 1px solid ${q.borderSoft};
  backdrop-filter: blur(10px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.5);
`,Fx=x.div`
  flex: 0 0 auto;
  font-family: ${ol.body};
  font-size: 13px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  color: ${q.textLabel};
`;function Dx(e){switch(e){case"ped":return u.jsx(ry,{});case"headBlend":return u.jsx(oy,{});case"faceFeatures":return u.jsx(py,{});case"headOverlays":return u.jsx(by,{});case"components":return u.jsx(Hc,{kind:"component"});case"props":return u.jsx(Hc,{kind:"prop"});case"tattoos":return u.jsx(dx,{});default:return null}}function Hx({id:e}){return u.jsx(Wx,{children:Dx(e)},e)}const Ux=Js`
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: none; }
`,Wx=x.div`
  animation: ${Ux} 0.28s cubic-bezier(0.2, 0.7, 0.2, 1) both;
`,Vx="data:image/svg+xml,%3csvg%20preserveAspectRatio='none'%20width='100%25'%20height='100%25'%20overflow='visible'%20style='display:%20block;'%20viewBox='0%200%20135.6%20135.6'%20fill='none'%20xmlns='http://www.w3.org/2000/svg'%3e%3cg%20id='Vector%201'%20filter='url(%23filter0_d_0_6)'%3e%3cpath%20d='M99.8%2035.8L35.8%2099.8'%20stroke='var(--stroke-0,%20white)'%20stroke-width='3'%20stroke-linecap='round'/%3e%3c/g%3e%3cdefs%3e%3cfilter%20id='filter0_d_0_6'%20x='0'%20y='0'%20width='135.6'%20height='135.6'%20filterUnits='userSpaceOnUse'%20color-interpolation-filters='sRGB'%3e%3cfeFlood%20flood-opacity='0'%20result='BackgroundImageFix'/%3e%3cfeColorMatrix%20in='SourceAlpha'%20type='matrix'%20values='0%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%20127%200'%20result='hardAlpha'/%3e%3cfeOffset/%3e%3cfeGaussianBlur%20stdDeviation='17.15'/%3e%3cfeComposite%20in2='hardAlpha'%20operator='out'/%3e%3cfeColorMatrix%20type='matrix'%20values='0%200%200%200%201%200%200%200%200%201%200%200%200%200%201%200%200%200%201%200'/%3e%3cfeBlend%20mode='normal'%20in2='BackgroundImageFix'%20result='effect1_dropShadow_0_6'/%3e%3cfeBlend%20mode='normal'%20in='SourceGraphic'%20in2='effect1_dropShadow_0_6'%20result='shape'/%3e%3c/filter%3e%3c/defs%3e%3c/svg%3e",Gx="data:image/svg+xml,%3csvg%20preserveAspectRatio='none'%20width='100%25'%20height='100%25'%20overflow='visible'%20style='display:%20block;'%20viewBox='0%200%20128.6%20128.6'%20fill='none'%20xmlns='http://www.w3.org/2000/svg'%3e%3cg%20id='Vector%203'%20filter='url(%23filter0_d_0_5)'%3e%3cpath%20d='M92.8%2035.8L35.8%2092.8'%20stroke='var(--stroke-0,%20%23D73338)'%20stroke-width='3'%20stroke-linecap='round'/%3e%3c/g%3e%3cdefs%3e%3cfilter%20id='filter0_d_0_5'%20x='0'%20y='0'%20width='128.6'%20height='128.6'%20filterUnits='userSpaceOnUse'%20color-interpolation-filters='sRGB'%3e%3cfeFlood%20flood-opacity='0'%20result='BackgroundImageFix'/%3e%3cfeColorMatrix%20in='SourceAlpha'%20type='matrix'%20values='0%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%20127%200'%20result='hardAlpha'/%3e%3cfeOffset/%3e%3cfeGaussianBlur%20stdDeviation='17.15'/%3e%3cfeComposite%20in2='hardAlpha'%20operator='out'/%3e%3cfeColorMatrix%20type='matrix'%20values='0%200%200%200%200.843137%200%200%200%200%200.2%200%200%200%200%200.219608%200%200%200%201%200'/%3e%3cfeBlend%20mode='normal'%20in2='BackgroundImageFix'%20result='effect1_dropShadow_0_5'/%3e%3cfeBlend%20mode='normal'%20in='SourceGraphic'%20in2='effect1_dropShadow_0_5'%20result='shape'/%3e%3c/filter%3e%3c/defs%3e%3c/svg%3e",Kx="data:image/svg+xml,%3csvg%20preserveAspectRatio='none'%20width='100%25'%20height='100%25'%20overflow='visible'%20style='display:%20block;'%20viewBox='0%200%20125.6%20125.6'%20fill='none'%20xmlns='http://www.w3.org/2000/svg'%3e%3cg%20id='Vector%204'%20filter='url(%23filter0_d_0_4)'%3e%3cpath%20d='M89.8%2035.8L35.8%2089.8'%20stroke='var(--stroke-0,%20%23D73338)'%20stroke-width='3'%20stroke-linecap='round'/%3e%3c/g%3e%3cdefs%3e%3cfilter%20id='filter0_d_0_4'%20x='0'%20y='0'%20width='125.6'%20height='125.6'%20filterUnits='userSpaceOnUse'%20color-interpolation-filters='sRGB'%3e%3cfeFlood%20flood-opacity='0'%20result='BackgroundImageFix'/%3e%3cfeColorMatrix%20in='SourceAlpha'%20type='matrix'%20values='0%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%200%20127%200'%20result='hardAlpha'/%3e%3cfeOffset/%3e%3cfeGaussianBlur%20stdDeviation='17.15'/%3e%3cfeComposite%20in2='hardAlpha'%20operator='out'/%3e%3cfeColorMatrix%20type='matrix'%20values='0%200%200%200%200.843137%200%200%200%200%200.2%200%200%200%200%200.219608%200%200%200%201%200'/%3e%3cfeBlend%20mode='normal'%20in2='BackgroundImageFix'%20result='effect1_dropShadow_0_4'/%3e%3cfeBlend%20mode='normal'%20in='SourceGraphic'%20in2='effect1_dropShadow_0_4'%20result='shape'/%3e%3c/filter%3e%3c/defs%3e%3c/svg%3e",Yx=""+new URL("noise-texture.J4V3NjRY.png",import.meta.url).href,Qx={ped:fg,headBlend:pg,faceFeatures:hg,headOverlays:mg,components:gg,props:yg,tattoos:xg},{color:sr,font:ou,radius:Zx}=le,Xx=[{src:Kx,left:-72.8,top:238.2,size:125.6},{src:Vx,left:-57.8,top:741.2,size:135.6},{src:Gx,left:101.2,top:849.2,size:128.6}];function Jx({sections:e,active:t,onSelect:n}){const{t:r,config:o,exit:i}=Ge(),l=o?.branding;return u.jsxs(qx,{children:[u.jsx(ev,{}),u.jsx(tv,{}),Xx.map((a,s)=>u.jsx(nv,{src:a.src,style:{left:a.left,top:a.top,width:a.size,height:a.size}},s)),u.jsx(rv,{}),u.jsx(ov,{children:l?.useLogo&&l.logo?u.jsx(lv,{src:l.logo,alt:l.name||"Logo",style:{width:l.logoWidth?`${l.logoWidth}px`:void 0,height:l.logoHeight?`${l.logoHeight}px`:"auto"}}):u.jsx(iv,{children:l?.name??"NANO SCRIPTS"})}),u.jsx(av,{children:e.map(a=>{const s=a.id===t,c=Qx[a.id];return u.jsxs(uv,{onClick:()=>n(a.id),children:[u.jsx(sv,{}),u.jsx(li,{$active:s,children:u.jsx(c,{size:22})}),u.jsx(Xp,{$active:s,children:r(a.titleKey)})]},a.id)})}),o?.enableExit!==!1&&u.jsx(cv,{onClick:i,children:r("app.quit")})]})}const qx=x.div`
  position: absolute;
  left: 0;
  top: 0;
  width: ${le.layout.railWidth}px;
  height: ${le.layout.stageHeight}px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
`,ev=x.div`
  position: absolute;
  inset: 0;
  background: radial-gradient(125% 75% at 100% 50%, ${sr.railTop} 0%, ${sr.railBottom} 100%);
  opacity: ${le.panelOpacity};
`,tv=x.div`
  position: absolute;
  inset: 0;
  background-image: url(${Yx});
  background-size: 1024px 1024px;
  background-position: top left;
  opacity: 0.19;
  mix-blend-mode: overlay;
  pointer-events: none;
`,nv=x.img`
  position: absolute;
  pointer-events: none;
  opacity: 0.85;
  border-radius: 9999px;
`,rv=x.div`
  position: absolute;
  top: -20px;
  left: 40px;
  width: 26px;
  height: 120px;
  transform: rotate(40deg);
  transform-origin: top left;
  border-radius: 9999px;
  background: rgba(255, 255, 255, 0.55);
  box-shadow: 0 0 100px 20px rgba(255, 255, 255, 0.22);
  filter: blur(50px);
  pointer-events: none;
  z-index: 2;
`,ov=x.div`
  position: relative;
  margin-top: 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
`,iv=x.div`
  font-family: ${ou.display};
  font-size: 24px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  text-align: center;
  color: ${sr.text};
`,lv=x.img`
  display: block;
  max-width: 140px;
  object-fit: contain;
  pointer-events: none;
  user-select: none;
`,av=x.div`
  position: relative;
  flex: 1;
  min-height: 0;
  margin-top: 26px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 28px;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 4px 0;
  &::-webkit-scrollbar { width: 0; }
`,sv=x.div`
  position: absolute;
  top: 0;
  width: 28px;
  height: 2px;
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0) 0%,
    rgba(255, 255, 255, 0.44) 50%,
    rgba(255, 255, 255, 0) 100%
  );
`,li=x.div`
  width: 40px;
  height: 40px;
  border-radius: ${Zx.lg};
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid ${e=>e.$active?sr.buttonFrom:"rgba(255,255,255,0.14)"};
  background: ${e=>e.$active?"var(--accent-badge)":"radial-gradient(circle at 50% 35%, rgba(226,226,226,0.34), rgba(142,142,142,0.34) 75%, rgba(114,114,114,0.34) 100%)"};
  box-shadow: ${e=>e.$active?"0 4px 41px 1px rgba(var(--accent-strong-rgb),0.40)":"0 4px 41px 1px rgba(255,255,255,0.25)"};
  color: #fff;
  transition: transform 0.2s cubic-bezier(0.2, 0.7, 0.2, 1), border-color 0.18s ease, box-shadow 0.18s ease;

  svg { opacity: ${e=>e.$active?1:.5}; transition: opacity 0.18s ease; }
`,Xp=x.div`
  font-family: ${ou.body};
  font-size: 17px;
  /* Allow multi-word labels (e.g. "Face Features") to wrap onto two tight lines,
     while long single words ("Inheritance") stay on one. */
  max-width: 88px;
  text-align: center;
  white-space: normal;
  line-height: 1.0;
  color: ${e=>e.$active?sr.text:"rgba(255,255,255,0.7)"};
  transition: color 0.18s ease;
`,uv=x.button`
  position: relative;
  width: 100%;
  background: none;
  border: none;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding-top: 18px;

  &:hover ${li} { transform: scale(1.1); }
  &:hover ${li} svg { opacity: 1; }
  &:hover ${Xp} { color: ${sr.text}; }
  &:active ${li} { transform: scale(1.03); }
`,cv=x.button`
  position: relative;
  flex: none;
  margin-bottom: 31px;
  width: 80px;
  height: 36px;
  border: none;
  border-radius: 10px;
  background: #ffffff;
  color: #000000;
  font-family: ${ou.body};
  font-weight: 600;
  font-size: 14px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  cursor: pointer;
  box-shadow: 0 10px 22.8px 0 rgba(255, 255, 255, 0.18);
  transition: filter 0.15s ease, transform 0.1s ease;
  &:hover { filter: brightness(0.92); }
  &:active { transform: translateY(1px); }
`,dv=""+new URL("panel.DpK-Y8xd.png",import.meta.url).href,{color:kt,font:il,radius:Jp,shadow:fv,layout:se}=le;function pv(){const{visible:e,ready:t,failed:n,config:r,t:o,save:i,exit:l,setCamera:a,orbitCamera:s,zoomCamera:c,turnAround:m}=Ge(),h=j.useMemo(()=>Ga(r),[r]),[f,w]=j.useState("ped"),v=j.useRef(null);j.useLayoutEffect(()=>{v.current&&(v.current.scrollTop=0)},[f]),j.useEffect(()=>{h.length&&!h.some($=>$.id===f)&&w(h[0].id)},[h,f]),j.useEffect(()=>{const $=h.find(R=>R.id===f);e&&t&&$&&a($.camera)},[f,e,t,h,a]),j.useEffect(()=>{if(!e)return;const $=R=>{R.key==="Escape"&&r?.enableExit!==!1&&l()};return window.addEventListener("keydown",$),()=>window.removeEventListener("keydown",$)},[e,r,l]);const k=j.useRef(!1),_=j.useRef({dx:0,dy:0}),p=j.useRef(null),d=()=>{p.current=null;const{dx:$,dy:R}=_.current;_.current={dx:0,dy:0},($||R)&&s($,R)},g=$=>{k.current=!0,$.currentTarget.setPointerCapture($.pointerId)},S=$=>{k.current&&(_.current.dx+=$.movementX,_.current.dy+=$.movementY,p.current===null&&(p.current=requestAnimationFrame(d)))},y=$=>{k.current=!1,$.currentTarget.hasPointerCapture($.pointerId)&&$.currentTarget.releasePointerCapture($.pointerId)},C=$=>{c($.deltaY>0?.25:-.25)};if(j.useEffect(()=>()=>{p.current!==null&&cancelAnimationFrame(p.current)},[]),!e)return null;const b=h.find($=>$.id===f);return u.jsxs(hv,{className:"app-stage",children:[u.jsx(mv,{onPointerDown:g,onPointerMove:S,onPointerUp:y,onPointerCancel:y,onWheel:C}),u.jsx(Jx,{sections:h,active:f,onSelect:w}),u.jsx(Wc,{style:{left:se.railWidth-2}}),u.jsxs(gv,{children:[u.jsx(yv,{}),u.jsxs(xv,{children:[u.jsx(wv,{}),u.jsx(vv,{children:o(b?b.titleKey:"app.title")}),u.jsx(kv,{children:o("app.subtitle")})]}),u.jsx(Sv,{ref:v,children:t&&!n&&b?u.jsx(Hx,{id:f}):t&&n?u.jsx(Vc,{children:o("app.loadFailed")==="app.loadFailed"?"The editor could not load its data. Please try again.":o("app.loadFailed")}):u.jsx(Vc,{children:o("app.loading")})}),u.jsxs($v,{children:[u.jsx(bv,{}),u.jsx(Cv,{onClick:i,children:o("app.continueButton")})]})]}),u.jsx(Wc,{style:{left:se.panelX+se.panelWidth-2}}),u.jsxs(_v,{children:[u.jsxs(Ul,{onClick:m,children:[u.jsx(sg,{size:18}),u.jsx("span",{children:o("app.rotate")})]}),u.jsx(Gc,{}),u.jsxs(Ul,{onClick:()=>c(-.6),children:[u.jsx(ug,{size:18}),u.jsx("span",{children:o("app.zoom")})]}),u.jsx(Gc,{}),u.jsxs(Ul,{onClick:()=>a("default"),children:[u.jsx(dg,{size:18}),u.jsx("span",{children:o("app.reset")})]})]})]})}const hv=x.div`
  font-family: ${il.body};
`,mv=x.div`
  position: absolute;
  left: ${se.panelX+se.panelWidth}px;
  top: 0;
  width: ${se.stageWidth-(se.panelX+se.panelWidth)}px;
  height: ${se.stageHeight}px;
  cursor: grab;
  touch-action: none;
  &:active {
    cursor: grabbing;
  }
`,Wc=x.div`
  position: absolute;
  top: 0;
  width: 2px;
  height: ${se.stageHeight}px;
  /* White in the middle, fading smoothly to transparent at both ends (Figma). */
  background: linear-gradient(
    180deg,
    rgba(255, 255, 255, 0) 0%,
    rgba(255, 255, 255, 0.85) 50%,
    rgba(255, 255, 255, 0) 100%
  );
`,gv=x.div`
  position: absolute;
  left: ${se.panelX}px;
  top: 0;
  width: ${se.panelWidth}px;
  height: ${se.stageHeight}px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
`,yv=x.div`
  position: absolute;
  inset: 0;
  background-image: url(${dv});
  background-size: 100% 100%;
  background-position: center;
  pointer-events: none;
`,xv=x.div`
  position: relative;
  padding: 58px ${se.contentPad}px 0;
  flex: none;
`,vv=x.h1`
  display: inline-block;
  font-family: ${il.display};
  font-weight: 400;
  font-size: 48px;
  line-height: 1;
  letter-spacing: 1px;
  /* Radial fill: bright in the centre of the word, fading outward (matches Figma). */
  background: radial-gradient(ellipse at 50% 50%, #ffffff 0%, rgba(222, 222, 222, 0.92) 48%, rgba(150, 150, 150, 0.55) 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  text-transform: uppercase;
`,wv=x.div`
  margin-bottom: 14px;
  width: 64px;
  height: 2px;
  background: #d9d9d9;
`,kv=x.p`
  font-size: 15px;
  color: ${kt.textFaint};
  max-width: 364px;
`,Sv=x.div`
  position: relative;
  flex: 1;
  min-height: 0;
  padding: 36px ${se.contentPad}px 20px;
  overflow-y: auto;
  overflow-x: hidden;
`,Vc=x.div`
  padding: 40px 0;
  text-align: center;
  font-size: 13px;
  color: ${kt.textFaint};
`,$v=x.div`
  position: relative;
  flex: none;
  padding: 0 ${se.contentPad}px 31px;
`,bv=x.div`
  height: 2px;
  border-radius: 27px;
  background: ${kt.divider};
  margin-bottom: 22px;
`,Cv=x.button`
  width: 100%;
  height: 58px;
  border: none;
  border-radius: ${Jp.xl};
  background: linear-gradient(90deg, ${kt.buttonFrom}, ${kt.buttonTo});
  box-shadow: ${fv.buttonGlow};
  color: ${kt.text};
  font-family: ${il.body};
  font-weight: 500;
  font-size: 16px;
  letter-spacing: 2px;
  text-transform: uppercase;
  cursor: pointer;
  transition: filter 0.15s ease, transform 0.1s ease;
  &:hover { filter: brightness(1.08); }
  &:active { transform: translateY(1px); }
`,_v=x.div`
  position: absolute;
  left: ${se.panelX+se.panelWidth+(1920-(se.panelX+se.panelWidth))/2}px;
  transform: translateX(-50%);
  top: 1021px;
  height: 40px;
  padding: 0 16px;
  display: flex;
  align-items: center;
  gap: 16px;
  border-radius: ${Jp.md};
  background: ${kt.controlBar};
  border: 1px solid ${kt.controlBarBorder};
  backdrop-filter: blur(8px);
`,Ul=x.button`
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  color: ${kt.text};
  opacity: 0.65;
  font-family: ${il.body};
  font-weight: 500;
  font-size: 14px;
  cursor: pointer;
  transition: opacity 0.15s ease;
  &:hover { opacity: 1; }
`,Gc=x.div`
  width: 1px;
  height: 16px;
  background: ${kt.controlSep};
`,{color:je,font:qp,radius:$o}=le,Ev=[{name:"Red (default)",hex:"#ff454b"},{name:"Blue",hex:"#3b82f6"},{name:"Cyan",hex:"#06b6d4"},{name:"Green",hex:"#22c55e"},{name:"Lime",hex:"#84cc16"},{name:"Amber",hex:"#f59e0b"},{name:"Orange",hex:"#f97316"},{name:"Pink",hex:"#ec4899"},{name:"Purple",hex:"#a855f7"},{name:"White",hex:"#e5e7eb"}];function jv(){const[e,t]=j.useState(!1),[n,r]=j.useState(Va);function o(i){r(i),qs(i)}return u.jsxs(Tv,{children:[e&&u.jsxs(Pv,{children:[u.jsxs(Nv,{children:["Theme color ",u.jsx(Ov,{children:"DEV"})]}),u.jsxs(Rv,{children:[u.jsx(Mv,{type:"color",value:n,onChange:i=>o(i.target.value)}),u.jsx(zv,{children:n.toUpperCase()})]}),u.jsx(Av,{children:Ev.map(i=>u.jsx(Iv,{title:i.name,style:{background:i.hex},$active:i.hex.toLowerCase()===n.toLowerCase(),onClick:()=>o(i.hex)},i.hex))}),u.jsx(Bv,{onClick:()=>o(Va),children:"Reset to default"})]}),u.jsx(Lv,{$open:e,onClick:()=>t(i=>!i),title:"Primary colour (dev tool)",children:u.jsx("svg",{viewBox:"0 0 24 24",width:"20",height:"20","aria-hidden":!0,children:u.jsx("path",{d:"M12 3s6 6.6 6 11a6 6 0 0 1-12 0c0-4.4 6-11 6-11z",fill:"currentColor"})})})]})}const Tv=x.div`
  position: fixed;
  top: 16px;
  right: 16px;
  z-index: 2147483000;
  font-family: ${qp.body};
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
`,Lv=x.button`
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: ${je.accent};
  background: rgba(20, 20, 20, 0.85);
  backdrop-filter: blur(6px);
  border: 1px solid ${e=>e.$open?je.accent:je.border};
  border-radius: ${$o.md};
  box-shadow: 0 4px 18px rgba(0, 0, 0, 0.5);
  transition: border-color 0.15s ease, transform 0.12s ease;
  svg { filter: drop-shadow(0 0 6px ${je.accentSoft}); }
  &:hover { transform: translateY(-1px); border-color: ${je.accent}; }
  &:active { transform: translateY(0); }
`,Pv=x.div`
  width: 222px;
  padding: 14px;
  background: rgba(18, 18, 18, 0.94);
  backdrop-filter: blur(10px);
  border: 1px solid ${je.border};
  border-radius: ${$o.lg};
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.55);
  display: flex;
  flex-direction: column;
  gap: 12px;
`,Nv=x.div`
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  color: ${je.text};
`,Ov=x.span`
  margin-left: auto;
  font-size: 9px;
  letter-spacing: 1.5px;
  color: ${je.accent};
  border: 1px solid ${je.accentSoft};
  border-radius: ${$o.pill};
  padding: 2px 7px;
`,Rv=x.div`
  display: flex;
  align-items: center;
  gap: 10px;
`,Mv=x.input`
  width: 44px;
  height: 30px;
  padding: 0;
  border: 1px solid ${je.border};
  border-radius: ${$o.sm};
  background: none;
  cursor: pointer;
  &::-webkit-color-swatch-wrapper { padding: 3px; }
  &::-webkit-color-swatch { border: none; border-radius: 2px; }
`,zv=x.span`
  font-size: 13px;
  letter-spacing: 1px;
  color: ${je.textMuted};
  font-variant-numeric: tabular-nums;
`,Av=x.div`
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
`,Iv=x.button`
  width: 22px;
  height: 22px;
  border-radius: 50%;
  cursor: pointer;
  border: 2px solid ${e=>e.$active?"#fff":"transparent"};
  outline: 1px solid rgba(0, 0, 0, 0.4);
  outline-offset: -1px;
  transition: transform 0.12s ease;
  &:hover { transform: scale(1.12); }
`,Bv=x.button`
  font-family: ${qp.body};
  font-size: 12px;
  color: ${je.textMuted};
  background: ${je.surface05};
  border: 1px solid ${je.border};
  border-radius: ${$o.sm};
  padding: 8px;
  cursor: pointer;
  transition: color 0.12s ease, border-color 0.12s ease;
  &:hover { color: #fff; border-color: ${je.accent}; }
`;function e0(){const{stageWidth:e,stageHeight:t}=le.layout,n=Math.min(window.innerWidth/e,window.innerHeight/t);document.documentElement.style.setProperty("--stage-scale",String(n))}e0();window.addEventListener("resize",e0);Wl.createRoot(document.getElementById("root")).render(u.jsxs(Fe.StrictMode,{children:[u.jsx(B1,{}),u.jsx(ag,{children:u.jsx(pv,{})}),pr()&&u.jsx(jv,{})]}));pr()&&(window.setAccent=qs,Object.assign(document.body.style,{backgroundImage:"url('/gta-preview.png')",backgroundSize:"cover",backgroundPosition:"center",backgroundRepeat:"no-repeat"}),setTimeout(()=>{window.dispatchEvent(new MessageEvent("message",{data:{type:"appearance_display",payload:{asynchronous:!1}}}))},50));
