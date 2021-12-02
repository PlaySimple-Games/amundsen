// This file should be used to add new config variables or overwrite defaults from config-default.ts

import {AppConfigCustom, BadgeStyle} from './config-types';

const configCustom: AppConfigCustom = {
  badges: {
      'gold': {
          style: BadgeStyle.INFO,
          displayName: 'Gold',
      },
      'silver': {
          style: BadgeStyle.INFO,
          displayName: 'Silver',
      },
      'bronze': {
          style: BadgeStyle.INFO,
          displayName: 'Bronze',
      }
  },
  browse: {
    curatedTags: [],
    showAllTags: true,
    showBadgesInHome: true,
  },
  analytics: {
    plugins: [],
  },
  mailClientFeatures: {
    feedbackEnabled: false,
    notificationsEnabled: false,
  },
  indexDashboards: {
    enabled: false,
  },
  indexUsers: {
    enabled: false,
  },
  indexFeatures: {
    enabled: false,
  },
  userIdLabel: 'email address',
  issueTracking: {
    enabled: false,
    issueDescriptionTemplate: '',
    projectSelection: {
      enabled: false,
      title: 'Issue project key (optional)',
      inputHint: '',
    },
  },
};

export default configCustom;
