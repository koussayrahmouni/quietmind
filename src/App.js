import { useState, useEffect, useMemo } from "react";
import { Route, Switch, Redirect, useLocation } from "react-router-dom";
import { ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import Icon from "@mui/material/Icon";
import VuiBox from "components/VuiBox";
import Sidenav from "examples/Sidenav";
import Configurator from "examples/Configurator";
import theme from "assets/theme";
import themeRTL from "assets/theme/theme-rtl";
import rtlPlugin from "stylis-plugin-rtl";
import { CacheProvider } from "@emotion/react";
import createCache from "@emotion/cache";
import AlertMonitor from "./admin/AlertMonitor";

// Component imports
import ChildDetail from "./child/ChildDetail";
import ChildForm from "./child/ChildForm";
import ChildUpdate from "./child/UpdateChildForm";
import ChildUpdateParent from "./child/UpdateParentChild";
import CreateUserPage from './admin/CreateUserPage';
import SignUpPage from './admin/SignUpPage';
import LoginPage from './layouts/authentication/sign-in/index';
import UsersPage from './admin/UsersPage';
import Profile from './layouts/profile/index';
import PredictionForm from "./admin/PredictionForm";
import Rapportgenrator from "./child/RaportGenerator";
import LocationTracker from "./child/LocationTracker";

// Routes
import routes from "routes";
import { useVisionUIController, setMiniSidenav, setOpenConfigurator } from "context";

export default function App() {
  const [controller, dispatch] = useVisionUIController();
  const { miniSidenav, direction, layout, openConfigurator, sidenavColor } = controller;
  const [onMouseEnter, setOnMouseEnter] = useState(false);
  const [rtlCache, setRtlCache] = useState(null);
  const { pathname } = useLocation();

  // Cache for the rtl
  useMemo(() => {
    const cacheRtl = createCache({
      key: "rtl",
      stylisPlugins: [rtlPlugin],
    });

    setRtlCache(cacheRtl);
  }, []);

  // Open sidenav when mouse enter on mini sidenav
  const handleOnMouseEnter = () => {
    if (miniSidenav && !onMouseEnter) {
      setMiniSidenav(dispatch, false);
      setOnMouseEnter(true);
    }
  };

  // Close sidenav when mouse leave mini sidenav
  const handleOnMouseLeave = () => {
    if (onMouseEnter) {
      setMiniSidenav(dispatch, true);
      setOnMouseEnter(false);
    }
  };

  // Change the openConfigurator state
  const handleConfiguratorOpen = () => setOpenConfigurator(dispatch, !openConfigurator);

  // Setting the dir attribute for the body element
  useEffect(() => {
    document.body.setAttribute("dir", direction);
  }, [direction]);

  // Setting page scroll to 0 when changing the route
  useEffect(() => {
    document.documentElement.scrollTop = 0;
    document.scrollingElement.scrollTop = 0;
  }, [pathname]);

  const getRoutes = (allRoutes) =>
    allRoutes.map((route) => {
      if (route.collapse) {
        return getRoutes(route.collapse);
      }

      if (route.route) {
        return <Route exact path={route.route} component={route.component} key={route.key} />;
      }

      return null;
    });

  const configsButton = (
    <VuiBox
      display="flex"
      justifyContent="center"
      alignItems="center"
      width="3.5rem"
      height="3.5rem"
      bgColor="info"
      shadow="sm"
      borderRadius="50%"
      position="fixed"
      right="2rem"
      bottom="2rem"
      zIndex={99}
      color="white"
      sx={{ cursor: "pointer" }}
      onClick={handleConfiguratorOpen}
    >
      <Icon fontSize="default" color="inherit">
        settings
      </Icon>
    </VuiBox>
  );

  return direction === "rtl" ? (
    <CacheProvider value={rtlCache}>
      <ThemeProvider theme={themeRTL}>
        <CssBaseline />
        {layout === "dashboard" && (
          <>
            <Sidenav
              color={sidenavColor}
              brand=""
              brandName="QUIET MIND"
              routes={routes}
              onMouseEnter={handleOnMouseEnter}
              onMouseLeave={handleOnMouseLeave}
            />
            <Configurator />
            {configsButton}
          </>
        )}
        {layout === "vr" && <Configurator />}
        <Switch>
          {getRoutes(routes)}
          <Route exact path="/detail/:id" component={ChildDetail} />
          <Route exact path="/add" component={ChildForm} />
          <Route exact path="/health-monitoring" component={PredictionForm} />
          <Redirect from="*" to="/dashboard" />
        </Switch>
        <AlertMonitor />
      </ThemeProvider>
    </CacheProvider>
  ) : (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {layout === "dashboard" && (
        <>
          <Sidenav
            color={sidenavColor}
            brand=""
            brandName="QUIET MIND"
            routes={routes}
            onMouseEnter={handleOnMouseEnter}
            onMouseLeave={handleOnMouseLeave}
          />
          <Configurator />
          {configsButton}
        </>
      )}
      {layout === "vr" && <Configurator />}
      <Switch>
        {getRoutes(routes)}
        <Route exact path="/detail/:id" component={ChildDetail} />
        <Route exact path="/add" component={ChildForm} />
        <Route exact path="/edit/:id" component={ChildUpdate} />
        <Route path="/edit/Parent/:id/:parentId" component={ChildUpdateParent} />
        <Route exact path="/create-user" component={CreateUserPage} />
        <Route exact path="/signup" component={SignUpPage} />
        <Route exact path="/login" component={LoginPage}/>
        <Route exact path="/users" component={UsersPage}/>
        <Route exact path="/profile" component={Profile}/>
        <Route path="/rapport/:childid" component={Rapportgenrator} />
        <Route path="/localisation/:childid" element={<LocationTracker />} />
        <Route exact path="/health-monitoring" component={PredictionForm} />
        <Redirect from="/login" to="/profile" />
      </Switch>
      <AlertMonitor />
    </ThemeProvider>
  );
}