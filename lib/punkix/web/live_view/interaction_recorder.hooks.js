const TARGET_FRAME = "iframe#target";
export default {
  mounted() {
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

    let interactions = [];
    let recordingName = null;

    const sendRecording = (data) => {
      if (isRecording && data.interactions.length !== 0) {
        console.log("sending", data)
        ("/test/store_interactions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": csrfToken
          },
          body: JSON.stringify(data)
        });
      }
    };

    const getSelector = (element) => {
      if (element.id && !element.id.startsWith("phx-")) {
        return `#${element.id}`;
      }
      let path = [];
      while (!element.id.startsWith("phx-")) {
        let tag = element.tagName.toLowerCase();
        let sibling = element;
        let nth = 1;
        while (sibling = sibling.previousElementSibling) {
          if (sibling.tagName.toLowerCase() === tag) nth++;
        }
        path.unshift(`${tag}:nth-of-type(${nth})`);
        element = element.parentNode;
      }
      return path.join(" > ");
    };

    const findParentForm = (element) => {
      let parent = element.parentNode
      while (parent.tagName !== "FORM") {
        parent = parent.parentNode;
      }
      return parent.id
    }

    const recordInteraction = (interaction) => {
      this.pushEventTo(this.el, "record-interaction", {name: recordingName, interaction: interaction});
    };

    const recordClick = (event) => {
      let target = event.target;
      let selector = getSelector(target);
      if (selector) {
        let interaction = {
          type: "click",
          selector: selector,
          timestamp: Date.now()
        };
        recordInteraction(interaction);
      }
    };

    const recordInput = (event) => {
      let target = event.target;
      let selector = getSelector(target);
      console.log(event)
      if (selector) {
        let interaction = {
          type: "input",
          selector: selector,
          name: target.name,
          form: findParentForm(target),
          value: target.value,
          timestamp: Date.now()
        };
        recordInteraction(interaction);
      }
    };
     const recordTextAssertion = (event) => {
      if (isRecording) {
        event.preventDefault(); // Prevent the context menu from appearing
        let target = event.target;
        console.log(target)
        let selector = getSelector(target);
        if (selector) {
          let interaction = {
            type: "assert_text",
            selector: selector,
            text: target.textContent.trim(),
            timestamp: Date.now()
          };
          recordInteraction(interaction);
        }
      }
    };
    const hasTextContent = (element) => {
      return !!element.text?.trim();
    };

    let isRecording = false;
    const inputElements = "input"
    const clickElements = "button, a, input[type='checkbox']"

    const applyListeners = (element) => {
      console.log(element.querySelectorAll(clickElements))
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
          console.log(el)
          console.log(el.removeEventListener("contextmenu", recordTextAssertion, true));
        }
      });
     };

    window.addEventListener("phx:redirect", (e) => {
      console.log(e)
    })


    window.addEventListener("phx:start-recording", (e) => {
      const isRecording = true;
      const recordingName = e.detail.module + Date.now().toString();
      const frame = document.createElement("iframe");
      frame.onload = function () {
        const body = this.contentDocument.body
        applyListeners(body);
        observer.observe(body,  {
          childList: true,
          subtree: true
        });
        interactions = [{
          type: "path",
          path: e.detail.path,
          timestamp: Date.now()
        }];
      };
      frame.src = e.detail.path;
      frame.id = "target";
      document.body.appendChild(frame);
    });

    window.addEventListener("phx:stop-recording", () => {
      sendRecording({ name: recordingName, interactions: interactions });
      const frame = document.querySelector(TARGET_FRAME);
      observer.disconnect()
      removeListeners(frame.contentDocument.body);
      frame.remove();
      isRecording = false;
    });


    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1) {
            console.log(node)
            applyListeners(node);
          }
        });
      });
    });
  }
}
