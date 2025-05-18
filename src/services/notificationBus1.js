const notify = {
    success: (message) => {
      console.log("Success:", message);
      // Add your actual notification system call here (Toast, Alert, etc.)
    },
    error: (message) => {
      console.error("Error:", message);
      // Add your actual notification system call here
    },
    info: (message) => {
      console.log("Info:", message);
      // Add your actual notification system call here
    }
  };
  
  export default notify;