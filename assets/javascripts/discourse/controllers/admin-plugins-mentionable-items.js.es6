import { default as discourseComputed, observes } from 'discourse-common/utils/decorators';
import { notEmpty } from "@ember/object/computed";
import MentionableItemLog from '../models/mentionable-item-log';
import Controller from "@ember/controller";
import discourseDebounce from "discourse/lib/debounce";
import { INPUT_DELAY } from "discourse-common/config/environment";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const mentionablesPath = "/admin/plugins/mentionable-items";

export default Controller.extend({
  refreshing: false,
  hasLogs: notEmpty("logs"),
  page: 0,
  canLoadMore: true,
  logs: [],

  @observes("filter")
  loadLogs: discourseDebounce(function() {
    if (!this.canLoadMore) return;

    this.set("refreshing", true);
    
    const page = this.page;
    let params = {
      page
    }
    
    const filter = this.filter;
    if (filter) {
      params.filter = filter;
    }

    MentionableItemLog.list(params)
      .then(result => {
        const logs = result.logs;
        const info = result.info;

        if (!logs || logs.length === 0) {
          this.set('canLoadMore', false);
        }
        if (filter && page == 0) {
          this.set('logs', A());
        }

        this.get('logs').pushObjects(
          logs.map(l => MentionableItemLog.create(l))
        );
        this.set('info', info);
      })
      .finally(() => this.set("refreshing", false));
  }, INPUT_DELAY),

  @discourseComputed('hasLogs', 'refreshing')
  noResults(hasLogs, refreshing) {
    return !hasLogs && !refreshing;
  },

  showMessage(key) {
    this.set('message', I18n.t(`mentionable_items.${key}`));
    setTimeout(() => { this.set('message', null); }, 20000);
  },

  actions: {
    loadMore() {
      let currentPage = this.get('page');
      this.set('page', currentPage += 1);
      this.loadLogs();
    },

    refresh() {
      this.setProperties({
        canLoadMore: true,
        page: 0,
        logs: []
      })
      this.loadLogs();
    },

    startImport() {
      ajax(mentionablesPath, {
        type: 'POST'
      }).then(result => {
        this.showMessage(result.success ? "import_started" : "error");
      }).catch(popupAjaxError)
        .finally(() => {
          this.set('loading', false);
        });
    },

    deleteData() {
      ajax(mentionablesPath, {
        type: 'DELETE'
      }).then(result => {
        console.log(result)
        this.showMessage(result.success ? "data_deleted" : "error");
      }).catch(popupAjaxError)
        .finally(() => {
          this.set('loading', false);
        });
    }
  }
});