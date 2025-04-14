let InteractionRecorder = {
	mounted() {
		const csrfToken = document
			.querySelector("meta[name='csrf-token']")
			.getAttribute("content");

		let interactions = [];
		let recordingName = null;

		const sendRecording = (data) => {
			if (isRecording && data.interactions.length !== 0) {
				console.log("sending", data);
				fetch("/test/record_interaction", {
					method: "POST",
					headers: {
						"Content-Type": "application/json",
						"X-CSRF-Token": csrfToken,
					},
					body: JSON.stringify(data),
				});
			}
		};

		const getSelector = (element) => {
			if (element.id) {
				return `#${element.id}`;
			}

			const parts = []; // Array to hold selector segments

			// Traverse up the DOM tree until an element with an ID is found
			while (element && element.nodeType === Node.ELEMENT_NODE) {
				// If the current element has an ID, use it as the starting point
				if (element.id) {
					parts.unshift(`#${element.id}`);
					break; // Stop traversal once we find an ID
				}

				// Calculate the element's position among its siblings
				let index = 1; // nth-child is 1-based
				let sibling = element.previousSibling;

				// Count all previous siblings (including non-element nodes)
				while (sibling) {
					index++;
					sibling = sibling.previousSibling;
				}

				// Format the selector segment (e.g., "div:nth-child(2)")
				const tagName = element.tagName.toLowerCase();
				parts.unshift(`${tagName}:nth-child(${index})`);

				// Move to the parent element
				element = element.parentElement;
			}

			// Join parts into a CSS selector (e.g., "#parent > div:nth-child(2)")
			return parts.join(" > ");
		};

		const findParentForm = (element) => {
			let parent = element.parentNode;
			while (parent.tagName !== "FORM") {
				parent = parent.parentNode;
			}
			return parent.id;
		};

		const recordInteraction = (interaction) => {
			if (recordingName && interaction.selector !== "#stop-recording") {
				interactions.push(interaction);
			}
		};

		const recordClick = (event) => {
			const target = event.target;
			const selector = getSelector(target);
			if (selector) {
				let interaction = {
					type: "click",
					selector: selector,
					timestamp: Date.now(),
				};
				recordInteraction(interaction);
			}
		};

		const recordInput = (event) => {
			const target = event.target;
			const selector = getSelector(target);
			console.log(event);
			if (selector) {
				let interaction = {
					type: "input",
					selector: selector,
					name: target.name,
					form: findParentForm(target),
					value: target.value,
					timestamp: Date.now(),
				};
				recordInteraction(interaction);
			}
		};
		const recordTextAssertion = (event) => {
			if (isRecording) {
				event.preventDefault(); // Prevent the context menu from appearing
				const target = event.target;
				console.log(target);
				const selector = getSelector(target);
				if (selector) {
					const interaction = {
						type: "assert_text",
						selector: selector,
						text: target.textContent.trim(),
						timestamp: Date.now(),
					};
					recordInteraction(interaction);
				}
			}
		};
		const hasTextContent = (element) => {
			return !!element.text?.trim();
		};

		let isRecording = false;
		const inputElements = "input, textarea, select";
		const clickElements = "input, button, a, select";

		const applyListeners = (element) => {
			element.querySelectorAll(inputElements).forEach((input) => {
				input.addEventListener("input", recordInput);
			});
			element.querySelectorAll(clickElements).forEach((clickable) => {
				clickable.addEventListener("click", recordClick);
			});
			element.querySelectorAll("*").forEach((el) => {
				if (hasTextContent(el)) {
					el.addEventListener("contextmenu", recordTextAssertion, true);
				}
			});
		};

		const removeListeners = (element) => {
			element.querySelectorAll(inputElements).forEach((input) => {
				input.removeEventListener("input", recordInput);
			});
			element.querySelectorAll(clickElements).forEach((clickable) => {
				clickable.removeEventListener("click", recordClick);
			});
			element.querySelectorAll("*").forEach((el) => {
				if (hasTextContent(el)) {
					console.log(el);
					console.log(
						el.removeEventListener("contextmenu", recordTextAssertion, true),
					);
				}
			});
		};

		window.addEventListener("phx:redirect", (e) => {
			console.log(e);
		});

		window.addEventListener("phx:start-recording", (e) => {
			isRecording = true;
			recordingName = e.detail.module + Date.now().toString();
			console.log(recordingName);
			applyListeners(document);
			observer.observe(document.body, {
				childList: true,
				subtree: true,
			});
			interactions = [
				{
					type: "path",
					path: e.detail.path,
					timestamp: Date.now(),
				},
			];
		});

		window.addEventListener("phx:stop-recording", () => {
			sendRecording({ name: recordingName, interactions: interactions });
			observer.disconnect();
			removeListeners(document);
			isRecording = false;
		});

		const observer = new MutationObserver((mutations) => {
			mutations.forEach((mutation) => {
				mutation.addedNodes.forEach((node) => {
					if (node.nodeType === 1) {
						console.log(node);
						applyListeners(node);
					}
				});
			});
		});
	},
};

export default InteractionRecorder;
