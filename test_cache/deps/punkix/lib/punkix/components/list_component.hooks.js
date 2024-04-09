import { Sortable } from "@shopify/draggable";

export default {
	mounted() {
		this.initDraggables();
	},

	initDraggables() {
		const target = this.el.dataset.target;
		const assign = this.el.dataset.assign;
		new Sortable(this.el, {
			draggable: ".sortable",
			handle: ".sortable-handle",
			animation: 150,
			classes: { "draggable:over": "has-background-info-light" },
		}).on("sortable:stop", (event) => {
			const newIndex = parseInt(event.data.newIndex);
			const oldIndex = parseInt(event.data.oldIndex);
			const payload = {
				from: oldIndex,
				to: newIndex,
			}
			if (oldIndex !== newIndex) {
				const event = `sort-${assign}`;
				if (target) {
					this.pushEventTo(target, event, payload);
				} else {
					this.pushEvent(event, payload);
				}
			}
		});
	},
}
