"use strict";

const Comunit = {
    initialized: false,
    autoInitComponents: true,
    components: {}
};

Comunit.components.entityRegionSelect = {
    initialized: false,
    listSelector: ".js-form-region-select",
    radioSelector: ".js-set-new-region",
    containerSelector: ".result-container",
    regionNameSelector: ".new-region-name",
    lists: [],
    init: function () {
        document.querySelectorAll(this.listSelector).forEach(this.addList);
        this.initialized = true;
    },
    addList: function (element) {
        const component = Comunit.components.entityRegionSelect;
        const list = {
            "element": element,
            "radio": element.querySelector(component.radioSelector),
            "container": element.querySelector(component.containerSelector),
            "name": element.querySelector(component.regionNameSelector)
        };
        list["url"] = list["container"].getAttribute("data-url");

        element.setAttribute("data-list-index", String(component.lists.length));
        list["radio"].addEventListener("click", component.radioChecked);

        component.lists.push(list);
    },
    radioChecked: function (e) {
        const component = Comunit.components.entityRegionSelect;
        const radio = e.target;
        const index = radio.closest(component.listSelector).getAttribute("data-list-index");
        const list = component.lists[index];

        list["radio"].value = "";
        list["name"].innerHTML = "";
        list["container"].innerHTML = "";

        component.loadRegions(list["url"], list["container"]);
    },
    loadRegions: function (url, container) {
        const component = Comunit.components.entityRegionSelect;
        const request = Biovision.jsonAjaxRequest("get", url, function () {
            const response = JSON.parse(this.responseText);
            if (response.hasOwnProperty("data")) {
                component.appendList(container, response["data"]);
            }
        });

        request.send();
    },
    appendList: function (container, data) {
        const component = Comunit.components.entityRegionSelect;
        const select = document.createElement("select");
        const index = container.closest(component.listSelector).getAttribute("data-list-index");
        const list = component.lists[index];
        const blankOption = document.createElement("option");
        blankOption.innerHTML = list["name"].innerHTML + "&darr;";
        blankOption.setAttribute("value", list["radio"].value);
        select.append(blankOption);

        data.forEach(function (item) {
            const option = document.createElement("option");
            option.innerHTML = item["attributes"]["name"];
            option.value = item["id"];
            if (parseInt(item["meta"]["child_count"]) > 0) {
                option.setAttribute("data-url", item["links"]["self"]);
            }

            select.append(option);
        });

        select.addEventListener("change", component.newRegion);

        container.append(select);
    },
    /**
     *
     * @param {Event} e
     * @type {Function}
     */
    newRegion: function (e) {
        const component = Comunit.components.entityRegionSelect;
        const select = e.target;
        const index = select.closest(component.listSelector).getAttribute("data-list-index");
        const list = component.lists[index];
        const option = select.options[select.selectedIndex];
        const container = list["container"];

        list["radio"].value = option.value;
        list["name"].innerHTML = option.innerHTML;
        if (option.hasAttribute("data-url")) {
            const url = option.getAttribute("data-url");
            const request = Biovision.jsonAjaxRequest("get", url, function () {
                const response = JSON.parse(this.responseText);

                if (response.hasOwnProperty("data")) {
                    const data = response["data"];
                    if (data.hasOwnProperty("relationships")) {
                        const relationships = data["relationships"];
                        if (relationships["children"].length > 0) {
                            component.appendList(container, relationships["children"]);
                        }
                    }
                }
            });

            component.removeSiblings(select);
            request.send();
        }
    },
    removeSiblings: function (current) {
        const nextSibling = current.nextElementSibling;

        if (nextSibling) {
            this.removeSiblings(nextSibling);
            nextSibling.remove();
        }
    }
};

Comunit.components.regionLinkRemover = {
    initialized: false,
    selector: ".region-link-destroy",
    buttons: [],
    init: function () {
        document.querySelectorAll(this.selector).forEach(this.apply);
        this.initialized = true;
    },
    apply: function (button) {
        const component = Comunit.components.regionLinkRemover;
        component.buttons.push(button);
        button.addEventListener("click", component.handler);
    },
    handler: function (event) {
        const button = event.target;
        if (confirm(button.getAttribute("data-message"))) {
            const url = button.getAttribute("data-url");
            const request = Biovision.jsonAjaxRequest("delete", url, function () {
                button.closest("li").remove();
            });
            request.send();
        }
    }
};

Comunit.components.regionLinkCreator = {
    initialized: false,
    selector: ".region-link-create",
    button: undefined,
    pattern: undefined,
    container: undefined,
    list: undefined,
    init: function () {
        this.button = document.querySelector(this.selector);
        if (this.button) {
            this.pattern = this.button.getAttribute("data-url");
            this.container = this.button.closest(".js-grouping-container");
            this.list = this.button.closest("div").querySelector(".js-form-region-select");
            this.button.addEventListener("click", this.handler);
            this.initialized = true;
        }
    },
    handler: function () {
        const component = Comunit.components.regionLinkCreator;
        const radio = component.list.querySelector("input:checked");
        const regionId = parseInt(radio.value);
        if (regionId > 0) {
            component.createLink(regionId);
        }
    },
    createLink: function (regionId) {
        const url = this.pattern.replace("_id_", String(regionId));
        Biovision.jsonAjaxRequest("put", url, this.insertLink).send();
    },
    insertLink: function () {
        const component = Comunit.components.regionLinkCreator;
        const regionName = component.list.querySelector(".new-region-name").innerHTML;
        let list = component.container.querySelector(".regions-user-linked");
        if (!list) {
            list = document.createElement("ul");
            list.classList.add("regions-user-linked");
            component.container.prepend(list);
        }
        const li = document.createElement("li");
        li.innerHTML = regionName;
        list.append(li);
    }
};

Biovision.components.comunit = Comunit;
