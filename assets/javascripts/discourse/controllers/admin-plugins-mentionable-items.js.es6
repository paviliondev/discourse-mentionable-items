import { default as discourseComputed, observes } from 'discourse-common/utils/decorators';
import { notEmpty } from "@ember/object/computed";
import MentionableItemLog from '../models/mentionable-item-log';
import Controller from "@ember/controller";
import discourseDebounce from "discourse/lib/debounce";
import { INPUT_DELAY } from "discourse-common/config/environment";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxaError } from "discourse/lib/ajax-error";

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
        if (!result || result.length === 0) {
          this.set('canLoadMore', false);
        }
        if (filter && page == 0) {
          this.set('logs', A());
        }

        this.get('logs').pushObjects(
          result.map(l => MentionableItemLog.create(l))
        );
      })
      .finally(() => this.set("refreshing", false));
  }, INPUT_DELAY),

  @discourseComputed('hasLogs', 'refreshing')
  noResults(hasLogs, refreshing) {
    return !hasLogs && !refreshing;
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
      ajax('/admin/plugins/mentionable-items', {
        type: 'POST'
      }).then(result => {
        if (result.success) {
          this.set('message', I18n.t('mentionable_items.import_started'));
        } else {
          this.set('message', I18n.t('mentionable_items.import_error'));
        }

        setTimeout(() => {
          this.set('message', null)
        }, 10000);
      }).catch(popupAjaxaError)
        .finally(() => {
          this.set('loading', false);
        });
    }
  }
});