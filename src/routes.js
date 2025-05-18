import Dashboard from "layouts/dashboard";
import Child from "child/ChildList";
import Tables from "layouts/tables";
import Billing from "layouts/billing";
import RTL from "layouts/rtl";
import Profile from "layouts/profile";
import SignIn from "layouts/authentication/sign-in";
import SignUpPage from "admin/SignUpPage";
import ParentChild from "child/ChildDetailParent";
import CaregiveChild from "child/ChildCaregiver";
import CreateUserPage from "admin/CreateUserPage";
import UsersPage from "admin/UsersPage"; // Import UsersPage
import PredictionForm from "admin/PredictionForm";
import { IoAddCircleOutline } from "react-icons/io5";
import { IoIosDocument } from "react-icons/io";
import { IoWoman } from "react-icons/io5";
import { IoPeople } from "react-icons/io5";
import { IoPerson } from "react-icons/io5";
import { IoPeopleSharp } from "react-icons/io5";
import { IoHappy } from "react-icons/io5";
import {IoPersonAddSharp} from "react-icons/io5"

const routes = [

  {
    type: "collapse",
    name: "Children",
    key: "Child",
    route: "/child/ChildList",
    icon: <IoHappy size="15px" color="white" />,
    component: Child,
    noCollapse: true,
  },
  { type: "collapse",
    name: "Health Monitoring",
    key: "health-monitoring",
    route: "/health-monitoring",
    icon: "monitor_heart", // Use appropriate Material icon
    component: PredictionForm,
  },
  {
    type: "collapse",
    name: "Parents",
    key: "ChildParent",
    route: "/child/ChildDetailParent",
    icon: <IoWoman size="15px" color="inherit" />,
    component: ParentChild,
    noCollapse: true,
  },
  
  {
    type: "collapse",
    name: "Create User",
    key: "create-user",
    route: "/create-user",
    icon: <IoPersonAddSharp size="15px" color="inherit" />,
    component: CreateUserPage,
    noCollapse: true,
  },
  {
    type: "collapse",
    name: "Users Management", // Name for UsersPage
    key: "users",
    route: "/admin/users", // Route path for UsersPage
    icon: <IoPeopleSharp size="15px" color="inherit" />,
    component: UsersPage,
    noCollapse: true,
  },
  { type: "title", title: "Account Pages", key: "account-pages" },
  {
    type: "collapse",
    name: "My Profile",
    key: "profile",
    route: "/profile",
    icon: <IoPerson size="15px" color="inherit" />,
    component: Profile,
    noCollapse: true,
  },
  {
    type: "collapse",
    name: "Sign In",
    key: "sign-in",
    route: "/authentication/sign-in",
    icon: <IoIosDocument size="15px" color="inherit" />,
    component: SignIn,
    noCollapse: true,
  },
  
  {
    type: "collapse",
    name: "Sign Up",
    key: "sign-up",
    route: "/admin/SignUpPage",
    icon: <IoIosDocument size="15px" color="inherit" />,
    component: SignUpPage,
    noCollapse: true,
  },
];

export default routes;
