'use strict';

module.exports = app => {
  const { router, controller, io } = app;
  const home = controller.home;
  router.get('/', home.index);
  router.get('/api/pixel', home.fetchAllColors);
  router.get('/api/users', home.fetchAllUsers);
};
