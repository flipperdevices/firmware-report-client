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

  const tooltip_footer = (tooltipItems) => {
    let i = tooltipItems[0].dataIndex;
    let string = "";
    string += "Commit: " + dev_data[i].commit.substring(0, 7);
    if (i > 0) {
      let diff =
        chart_data.datasets[0].data[i] - chart_data.datasets[0].data[i - 1];
      string += " | Diff: ";
      if (diff > 0) {
        string += "+";
      }
      string += diff + "\r\n";
    } else {
      string += "\r\n";
    }
    string += "\r\n";
    string += dev_data[i].commit_msg;
    return string;
  };

  const chart_options = {
    legend: {
      display: false,
    },
    responsive: true,
    plugins: {
      tooltip: {
        callbacks: {
          footer: tooltip_footer,
        },
      },
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
