<script>
  import { Line } from "svelte-chartjs";
  import "chart.js/auto";

  let server = "http://127.0.0.1:5000/";
  const total_flash_size = 1024 * 1024;

  async function api_get(api) {
    const res = await fetch(server + api, {
      method: "GET",
    });

    const json = await res.json();
    return json;
  }

  let dev_data = null;
  const chart_data = {
    labels: [],
    datasets: [
      {
        label: "Used Flash",
        data: [],
        backgroundColor: "rgba(255, 99, 132, 0.2)",
        borderColor: "rgba(255, 99, 132, 1)",
        borderWidth: 1,
      },
    ],
  };

  function get_diff(i, field, revert = false) {
    let string = "";
    let diff = 0;

    if (revert) {
      diff = dev_data[i - 1][field] - dev_data[i][field];
    } else {
      diff = dev_data[i][field] - dev_data[i - 1][field];
    }

    if (diff > 0) {
      string += "+";
    }
    string += diff;

    return string;
  }

  const commit_info = (i) => {
    let string = "";

    if (i > 0) {
      string += "used: " + get_diff(i, "free_flash_size", true) + "\r\n";
      string += ".bss: " + get_diff(i, "bss_size") + "\r\n";
      string += ".data: " + get_diff(i, "data_size") + "\r\n";
      string += ".rodata: " + get_diff(i, "rodata_size") + "\r\n";
      string += ".text: " + get_diff(i, "text_size") + "\r\n";
    }

    string += "-------------------------------------" + "\r\n";
    string += "Commit: " + dev_data[i].commit.substring(0, 7) + "\r\n";
    string += "-------------------------------------" + "\r\n";
    let message = dev_data[i].commit_msg;
    message = message.replace(/^\'+/, "").replace(/\'+$/, "");
    string += message;
    return string;
  };

  const tooltip_footer = (item) => {
    let i = item[0].dataIndex;
    let string = commit_info(i);
    return string;
  };

  const chart_options = {
    scales: {
      x: {
        display: false,
      },
      y: {
        display: true,
      },
    },
    responsive: true,
    plugins: {
      tooltip: {
        callbacks: {
          footer: tooltip_footer,
        },
      },
    },
    elements: {
      point: {
        // radius: 5,
        hoverRadius: 15,
      },
    },
    onClick: (event, item) => {
      let i = item[0].index;
      if (i > 0) {
        let id_current = dev_data[i].id;
        let id_previous = dev_data[i - 1].id;
        console.log(id_current, id_previous);
      }
      console.log(commit_info(i));
    },
  };

  async function fetch_dev_data() {
    if (dev_data == null) {
      dev_data = await api_get("api/v0/branch?branch_name=dev");
      for (let i = 0; i < dev_data.length; i++) {
        chart_data.labels.push(dev_data[i].datetime);
        chart_data.datasets[0].data.push(
          total_flash_size - dev_data[i].free_flash_size
        );
      }
    }
    return dev_data;
  }
</script>

<main>
  {#await fetch_dev_data()}
    <p>loading</p>
  {:then data}
    <Line data={chart_data} options={chart_options} />
    <!-- {#each data as item}
      <li>{item.datetime}</li>
    {/each} -->
  {:catch error}
    <p style="color: red">{error.message}</p>
  {/await}
</main>

<style>
</style>
