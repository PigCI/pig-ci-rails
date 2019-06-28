class PigCIProfilers extends HTMLElement {
  constructor() {
    super();
    this.data = JSON.parse(this.querySelector('[data-pig-ci-json]').innerText);
  }

  connectedCallback() {
    if(this.rendered) { return; }

    this.innerHTML = this._renderTable();
  }

  _renderTable(){
    var tablesHtml = '';

    for(const profiler in this.data) {
      tablesHtml += `
        <h2>${profiler}</h2>
        <table class="table">
          <thead>
            <tr>
              ${this._renderTableHeaders(profiler)}
            </tr>
          </thead>
          <tbody>
            ${this._renderTableBody(profiler)}
          </tbody>
        </table>
      `;
    }

    return tablesHtml;
  }

  _renderTableHeaders(profiler){
    return Object.keys(this.data[profiler][0]).map(function(currentValue){
      return `<th>${currentValue}</th>`;
    }).join('');
  }

  _renderTableBody(profiler){
    var finalOutput = '';

    for(const row in this.data[profiler]) {
      finalOutput += `
        <tr>
          ${this._renderTableRow(this.data[profiler][row])}
        </tr>
      `;
    }

    return finalOutput;
  }

  _renderTableRow(row){
    return Object.values(row).map(function(currentValue){
      return `<td>${currentValue}</td>`;
    }).join('');
  }
}
customElements.define('pig-ci-profilers', PigCIProfilers);


class PigCIResults extends HTMLElement {
  constructor() {
    super();
    this.data = JSON.parse(this.querySelector('[data-pig-ci-json]').innerText);
  }

  connectedCallback() {
    if(this.rendered) { return; }

    this.innerHTML = this._renderNavTabs() + this._renderTestRun();
  }

  _renderNavTabs(){
    var navTabs = '<ul class="nav nav-tabs mt-4" id="myTab" role="tablist">';

    for(const timestamp in this.data) {
      navTabs += `
        <li class="nav-item">
          <a class="nav-link" data-toggle="tab" href="#timestamp-${timestamp}" role="tab" aria-controls="${timestamp}">${new Date(timestamp * 1000).toLocaleString()}</a>
        </li>
      `;
    }
    navTabs += `</ul>`;

    return navTabs;
  }

  _renderTestRun(){
    var testRunHtml = '<div class="tab-content mt-3">';

    for(const timestamp in this.data) {
      testRunHtml += `
      <div class="tab-pane fade show" id="timestamp-${timestamp}" role="tabpanel" aria-labelledby="${timestamp}-tab">
        <pig-ci-profilers>
          <script data-pig-ci-json type="application/json">${JSON.stringify(this.data[timestamp])}</script>
        </pig-ci-profilers>
      </div>
      `;
    }

    testRunHtml += '</div>';
    return testRunHtml;
  }

}
customElements.define('pig-ci-results', PigCIResults);
