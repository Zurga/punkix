import PunkixHooks from "../_hooks";

/**
 * Controls `<details>` state on the client when LiveView updates the DOM.
 *
 * ---
 *
 * Inspired and derived from
 * - https://github.com/phoenixframework/phoenix_live_view/issues/2349#issuecomment-1430720906
 * - https://github.com/phoenixframework/phoenix_live_view/issues/2349#issuecomment-2164802079
 *
 * and https://elixirforum.com/t/dont-collapse-details/54278
 *
 * @param {HTMLElement} fromEl
 * @param {HTMLElement} toEl
 */
function preserveDetailsOpenState(fromEl, toEl) {
	if (
		!(fromEl instanceof HTMLDetailsElement) ||
		!(toEl instanceof HTMLDetailsElement)
	) {
		return
	}

	toEl.open = fromEl.open
}

export {preserveDetailsOpenState, PunkixHooks};
